package com.example.lab;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

@Singleton
@Startup
public class DbInit {

    private static final Logger log = Logger.getLogger(DbInit.class.getName());

    @Resource(lookup = "jdbc/labDS")
    private DataSource ds;

    @PostConstruct
    public void onStart() {
        log.info("DBINIT: started");

        try (Connection c = ds.getConnection()) {
            // если таблицы и авторы уже есть — пропускаем
            if (tableExists(c, "authors") && hasAnyRows(c, "authors")) {
                log.info("DBINIT: skip (authors already has data)");
                return;
            }

            runSqlFromResource("/db/schema.sql", c);
            runSqlFromResource("/db/init.sql", c);

            log.info("DBINIT: done");
        } catch (Exception e) {
            log.log(Level.SEVERE, "DBINIT: failed", e);
        }
    }

    private boolean tableExists(Connection c, String table) throws Exception {
        try (ResultSet rs = c.getMetaData().getTables(null, null, table, new String[]{"TABLE"})) {
            return rs.next();
        }
    }

    private boolean hasAnyRows(Connection c, String table) throws Exception {
        try (Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT 1 FROM " + table + " LIMIT 1")) {
            return rs.next();
        }
    }

    private void runSqlFromResource(String path, Connection c) throws Exception {
        try (var is = getClass().getResourceAsStream(path)) {
            if (is == null) {
                log.info("DBINIT: resource not found, skip: " + path);
                return;
            }

            String sql = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8)).lines().collect(Collectors.joining("\n"));

            // нарезка по ;
            for (String stmt : sql.split(";")) {
                String s = stmt.trim();
                if (s.isEmpty()) continue;

                try (Statement st = c.createStatement()) {
                    st.execute(s);
                }
            }

            log.info("DBINIT: executed " + path);
        }
    }
}