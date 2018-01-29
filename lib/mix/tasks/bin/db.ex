defmodule Mix.Tasks.Version.Bin.Db do
  use Mix.Task

  @shortdoc "Create 'rel/commands' helper scripts for managing database backup / restore"
  def run([]), do: run([nil, nil])
  def run([backup_root]), do: run([backup_root, nil])

  def run([backup_root, dbname]) do
    [
      "./rel/commands"
    ]
    |> Enum.each(fn dirname ->
      :ok = dirname |> Path.expand() |> File.mkdir_p!()
    end)

    appname = Mix.Project.config()[:app]
    default_root = "/src/#{appname}backup"
    backup_root = backup_root || default_root
    dbname = dbname || appname

    """
    #!/bin/bash

    NOW=${NOW:=$(date +"%Y%m%d%H%M%S")}
    VERSION=${VERSION:=$(mix version.current)}
    DBNAME=#{dbname}
    BACKUP_ROOT=#{backup_root}
    FNAME=${DBNAME}_${VERSION}_${NOW}

    (cd ${BACKUP_ROOT} && \\
     pg_dump --create --clean ${DBNAME} > ${FNAME}.sql && \\
     tar zcf ${FNAME}.tar.gz ${FNAME}.sql && \\
     ln -sf ${FNAME}.tar.gz ${DBNAME}_${VERSION}.tar.gz && \\
     ln -sf ${FNAME}.tar.gz ${DBNAME}.tar.gz && \\
     git add . && \\
     git commit -m "Backup ${DBNAME} v${VERSION} (${NOW})" && \\
     git push)
    """
    |> write!("./rel/commands/backup")

    """
    #!/bin/bash

    DBNAME=#{dbname}
    BACKUP_ROOT=#{backup_root}

    (cd ${BACKUP_ROOT} && \\
     psql -f $(tar zxfv ${DBNAME}.tar.gz))
    """
    |> write!("./rel/commands/restore")

    [
      "./rel/commands/backup",
      "./rel/commands/restore"
    ]
    |> Enum.each(fn filename ->
      :ok =
        filename
        |> Path.expand()
        |> File.chmod(0o755)
    end)

    IO.puts("Installed the following scripts into ./rel/commands")
    IO.puts("   + backup     \# Backup your database (named #{appname})")
    IO.puts("   + restore    \# Restore your database (named #{appname})")
    IO.puts("")

    IO.puts("To enable those to be part of the release,")
    IO.puts("then ensure you update your ./rel/config.exs with:")
    IO.puts("")

    example = """
    release :#{appname} do
      ...
      set commands: [
        "backup": "rel/commands/backup",
        "restore": "rel/commands/restore"
      ]
    end
    """

    IO.puts(example)
    IO.puts("")
  end

  defp write!(content, relative_name) do
    File.write!(relative_name |> Path.expand(), content)
  end
end
