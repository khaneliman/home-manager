{
  programs.sqls = {
    enable = true;
    settings = {
      lowercaseKeywords = true;
      connections = [
        {
          driver = "mysql";
          dataSourceName = "root:root@tcp(127.0.0.1:13306)/world";
        }
        {
          driver = "postgresql";
          dataSourceName = "host=127.0.0.1 port=15432 user=postgres password=mysecretpassword1234 dbname=dvdrental sslmode=disable";
        }
      ];
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/sqls/config.yml
    assertFileContent home-files/.config/sqls/config.yml ${builtins.toFile "sqls-config.yml" ''
      connections:
        - dataSourceName: root:root@tcp(127.0.0.1:13306)/world
          driver: mysql
        - dataSourceName: host=127.0.0.1 port=15432 user=postgres password=mysecretpassword1234 dbname=dvdrental sslmode=disable
          driver: postgresql
      lowercaseKeywords: true
    ''}
  '';
}
