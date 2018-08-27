package l3i.deais;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

// assumes the current class is called MyLogger
public class DB {

    static Connection con = null;

    public DB() throws SQLException {
        if (con == null) {
            try {
                Class.forName("org.postgresql.Driver").newInstance();
                String url = "";
                String user = "";
                String pass = "";
              
                con = DriverManager.getConnection(url, user, pass);
                if ((con != null) && (!con.isClosed())) {
                    System.out.println("Connected...");

                }

            } catch (Exception e) {
                //System.out.println("Error in connecting to database ");
                e.printStackTrace();

            }
        }

    }

    public void close() throws SQLException {
        con.close();
    }

    public int update(String query) throws Exception {

        Statement stmt;
        stmt = con.createStatement();
        int n = stmt.executeUpdate(query);
        stmt.close();
        return n;

    }

    public ResultSet query(String query) throws Exception {
        Statement stmt;
        stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
        ResultSet rs = stmt.executeQuery(query);
        return rs;
    }

    public static boolean isNumeric(String str) {
        try {
            double d = Double.parseDouble(str);
        } catch (NumberFormatException nfe) {
            return false;
        }
        return true;
    }

    public static String toJson(ResultSet resultSet) {
        if (resultSet == null) {
            return "";
        }
        try {
            JSONArray json = new JSONArray();
            ResultSetMetaData metadata = resultSet.getMetaData();
            int numColumns = metadata.getColumnCount();

            while (resultSet.next()) //iterate rows
            {
                JSONObject obj = new JSONObject();		//extends HashMap
                for (int i = 1; i <= numColumns; ++i) //iterate columns
                {
                    String column_name = metadata.getColumnName(i);

                    if (isNumeric(resultSet.getObject(column_name).toString())) {
                        obj.put(column_name, resultSet.getObject(column_name));
                    } else {
                        obj.put(column_name, resultSet.getObject(column_name).toString());
                    }
                }
                json.add(obj);
            }
            return json.toJSONString();
        } catch (Exception e) {
            return "";
        }
    }

}
