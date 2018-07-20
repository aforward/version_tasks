defmodule Mix.Tasks.Version.Bin.Db do
  use Mix.Task

  @moduledoc """
  This command will create helper scripts to manage the backup and restore
  of your database.

  There are two possible arguments

    * `backup_root` -- Where to store backups
    * `dbname`      -- The name of your database

  Both arugments are optional and default to

    * `backup_root` -- /src/{appname}backup
    * `dbname`      -- {appname}

  If your application is called namedb, then running the following

      mix version.bin.db

  Will create the following scripts

  * rel/commands/backup
  * rel/commands/restore

  The underlying script assumes lots of things, so be sure to test it out
  and tweak it to your needs (it is meant as a scaffold for you to customize).
  If there are any generic customizations you feel others might like, then
  please let me know through a Pull-Request against this project.

  Here's what the output of the backup looks like (may differ slightly
  based on the version you are running),

      #!/bin/bash

      NOW=${NOW:=$(date +"%Y%m%d%H%M%S")}
      VERSION=${VERSION:=$(mix version.current)}
      DBNAME=namedb
      BACKUP_ROOT=/src/namedbbackup
      FNAME=${DBNAME}_${VERSION}_${NOW}

      (cd ${BACKUP_ROOT} && \\
       pg_dump --create --clean ${DBNAME} > ${FNAME}.sql && \\
       tar zcf ${FNAME}.tar.gz ${FNAME}.sql && \\
       ln -sf ${FNAME}.tar.gz ${DBNAME}_${VERSION}.tar.gz && \\
       ln -sf ${FNAME}.tar.gz ${DBNAME}.tar.gz && \\
       git add . && \\
       git commit -m "Backup ${DBNAME} v${VERSION} (${NOW})" && \\
       git push)

  If you want these scripts available as part of your distillery release, then
  be sure to update your `./rel/config.exs` as follows [edit the `namedb` to
  that of your actual application].

      release :namedb do
        ...
        set commands: [
          "backup": "rel/commands/backup",
          "restore": "rel/commands/restore"
        ]
      end

  """

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

    if [ -z "$BACKUP_ROOT" ]
    then
      if [ -d "#{backup_root}" ]; then
        BACKUP_ROOT=#{backup_root}
      else
        BACKUP_ROOT=../#{appname}backup
      fi
    else
      BACKUP_ROOT=${BACKUP_ROOT}
    fi

    (cd ${BACKUP_ROOT} && \\
     psql -f $(tar zxfv ${DBNAME}.tar.gz 2>&1 | awk '{print $NF}'))
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
