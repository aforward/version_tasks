defmodule Mix.Tasks.Version.Bin.Db do
  use Mix.Task

  @shortdoc "Create 'bin/db' helper scripts for managing database backups"
  def run([]), do: run([nil])
  def run([backup_root]) do

    [
      "./bin/db",
    ]
    |> Enum.each(fn dirname ->
         :ok = dirname |> Path.expand |> File.mkdir_p!
       end)

    appname = Mix.Project.config[:app]
    default_root = "/src/#{appname}backup"
    backup_root = backup_root || default_root

    """
    #!/bin/bash

    NOW=${NOW:=$(date +"%Y%m%d%H%M%S")}
    VERSION=${VERSION:=$(mix version.current)}
    DBNAME=#{appname}
    BACKUP_ROOT=#{backup_root}
    FNAME=${DBNAME}_${VERSION}_${NOW}

    (cd ${BACKUP_ROOT} && \
     pg_dump --clean ${DBNAME} > ${FNAME}.sql && \
     tar zcf ${FNAME}.tar.gz ${FNAME}.sql && \
     ln -sf ${FNAME}.tar.gz ${DBNAME}_${VERSION}.tar.gz && \
     ln -sf ${FNAME}.tar.gz ${DBNAME}.tar.gz && \
     git add .
     git commit -m "Backup ${DBNAME} v${VERSION} (${NOW})" && \
     git push)
    """
    |> write!("./bin/db/backup")

    """
    #!/bin/bash

    DBNAME=#{appname}
    BACKUP_ROOT=#{backup_root}

    (cd ${BACKUP_ROOT} && \
     psql -d ${DBNAME} -f $(tar zxfv ${DBNAME}.tar.gz))
    """
    |> write!("./bin/db/restore")


    [
      "./bin/db/backup",
      "./bin/db/restore",
    ]
    |> Enum.each(fn filename ->
         :ok = filename
               |> Path.expand
               |> File.chmod(0o755)
       end)

    IO.puts "Installed the following scripts into ./bin/db"
    IO.puts "   + backup     \# Backup your database (named #{appname}"
    IO.puts "   + restore    \# Restore your database (named #{appname}"
    IO.puts ""

  end

  defp write!(content, relative_name) do
    File.write!(relative_name |> Path.expand, content)
  end

end