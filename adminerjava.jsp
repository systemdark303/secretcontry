<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>JSP DB Manager - With Edit/Delete</title>
    <style>
        body { font-family: monospace; margin: 20px; background: #1e1e1e; color: #d4d4d4; }
        input, select, textarea, button { background: #0d7377; color: white; border: none; padding: 8px; margin: 5px; }
        a { color: #00adb5; text-decoration: none; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #555; padding: 8px; text-align: left; }
        th { background: #0d7377; }
        .error { color: #ff6b6b; }
        .success { color: #4ecdc4; }
        .sidebar { float: left; width: 250px; margin-right: 20px; }
        .content { float: left; width: calc(100% - 280px); }
        .clearfix { clear: both; }
        .edit-form { background: #2d2d2d; padding: 15px; margin-top: 20px; border-radius: 5px; }
    </style>
</head>
<body>
<h1>🗄️ JSP DB Manager - Full Edit/Delete</h1>
<hr/>

<%
    // Session variables
    String jdbcUrl = (String) session.getAttribute("jdbcUrl");
    String dbUser = (String) session.getAttribute("dbUser");
    String dbPass = (String) session.getAttribute("dbPass");
    String selectedDb = (String) session.getAttribute("selectedDb");
    String selectedTable = (String) session.getAttribute("selectedTable");
    
    // Get parameters
    String newJdbc = request.getParameter("jdbcUrl");
    String newUser = request.getParameter("dbUser");
    String newPass = request.getParameter("dbPass");
    String newDb = request.getParameter("selectedDb");
    String newTable = request.getParameter("selectedTable");
    String action = request.getParameter("action");
    String sqlQuery = request.getParameter("sqlQuery");
    
    // Edit parameters
    String editId = request.getParameter("editId");
    String editColumn = request.getParameter("editColumn");
    String editValue = request.getParameter("editValue");
    String deleteId = request.getParameter("deleteId");
    String idColumn = request.getParameter("idColumn");
    
    // Update session
    if (newJdbc != null && !newJdbc.isEmpty()) {
        jdbcUrl = newJdbc;
        session.setAttribute("jdbcUrl", jdbcUrl);
    }
    if (newUser != null) {
        dbUser = newUser;
        session.setAttribute("dbUser", dbUser);
    }
    if (newPass != null) {
        dbPass = newPass;
        session.setAttribute("dbPass", dbPass);
    }
    if (newDb != null) {
        selectedDb = newDb;
        session.setAttribute("selectedDb", selectedDb);
    }
    if (newTable != null) {
        selectedTable = newTable;
        session.setAttribute("selectedTable", selectedTable);
    }
    
    // Default values
    if (jdbcUrl == null) jdbcUrl = "jdbc:mysql://localhost:3306/";
    if (dbUser == null) dbUser = "root";
    if (dbPass == null) dbPass = "";
    
    Connection conn = null;
    
    // Try to connect
    try {
        Class.forName("com.mysql.jdbc.Driver");
        if (selectedDb != null && !selectedDb.isEmpty() && !jdbcUrl.endsWith(selectedDb)) {
            String baseUrl = jdbcUrl.endsWith("/") ? jdbcUrl : jdbcUrl + "/";
            conn = DriverManager.getConnection(baseUrl + selectedDb, dbUser, dbPass);
        } else {
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
        }
    } catch(Exception e) {
        // Not connected yet
    }
    
    // ========== DELETE ROW ==========
    if (deleteId != null && selectedTable != null && idColumn != null) {
        try {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("DELETE FROM " + selectedTable + " WHERE " + idColumn + " = '" + deleteId + "'");
            out.println("<div class='success'>✅ Row deleted successfully!</div>");
            stmt.close();
        } catch(Exception e) {
            out.println("<div class='error'>❌ Delete failed: " + e.getMessage() + "</div>");
        }
    }
    
    // ========== UPDATE ROW ==========
    if (editId != null && selectedTable != null && editColumn != null && editValue != null) {
        try {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("UPDATE " + selectedTable + " SET " + editColumn + " = '" + editValue + "' WHERE " + idColumn + " = '" + editId + "'");
            out.println("<div class='success'>✅ Row updated successfully!</div>");
            stmt.close();
        } catch(Exception e) {
            out.println("<div class='error'>❌ Update failed: " + e.getMessage() + "</div>");
        }
    }
    
    // ========== EXECUTE SQL ==========
    if (action != null && action.equals("exec") && sqlQuery != null && !sqlQuery.trim().isEmpty()) {
        try {
            Statement stmt = conn.createStatement();
            if (sqlQuery.trim().toLowerCase().startsWith("select")) {
                ResultSet rs = stmt.executeQuery(sqlQuery);
                ResultSetMetaData meta = rs.getMetaData();
                int cols = meta.getColumnCount();
                out.println("<div class='success'>✅ Query executed</div>");
                out.println("<div class='info'>" + sqlQuery + "</div>");
                out.println("<table border='1'>");
                out.println("<tr>");
                for (int i = 1; i <= cols; i++) {
                    out.println("<th>" + meta.getColumnName(i) + "</th>");
                }
                out.println("</tr>");
                int rows = 0;
                while (rs.next()) {
                    out.println("<tr>");
                    for (int i = 1; i <= cols; i++) {
                        out.println("<td>" + (rs.getString(i) != null ? rs.getString(i) : "NULL") + "</td>");
                    }
                    out.println("</tr>");
                    rows++;
                }
                out.println("</table>");
                out.println("<div class='success'>✅ " + rows + " rows</div>");
                rs.close();
            } else {
                int affected = stmt.executeUpdate(sqlQuery);
                out.println("<div class='success'>✅ Query executed. " + affected + " rows affected.</div>");
                out.println("<div class='info'>" + sqlQuery + "</div>");
            }
            stmt.close();
        } catch(Exception e) {
            out.println("<div class='error'>❌ Error: " + e.getMessage() + "</div>");
        }
    }
    
    // ========== DROP TABLE ==========
    if (action != null && action.equals("dropTable") && selectedTable != null) {
        try {
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("DROP TABLE " + selectedTable);
            out.println("<div class='success'>✅ Table dropped: " + selectedTable + "</div>");
            selectedTable = null;
            session.setAttribute("selectedTable", selectedTable);
            stmt.close();
        } catch(Exception e) {
            out.println("<div class='error'>❌ Error: " + e.getMessage() + "</div>");
        }
    }
%>

<!-- Sidebar -->
<div class="sidebar">
    <h3>🔌 Connection</h3>
    <form method="get">
        <input type="text" name="jdbcUrl" value="<%= jdbcUrl %>" placeholder="JDBC URL" size="25"><br/>
        <input type="text" name="dbUser" value="<%= dbUser %>" placeholder="Username"><br/>
        <input type="password" name="dbPass" value="<%= dbPass %>" placeholder="Password"><br/>
        <button type="submit" name="action" value="connect">Connect</button>
    </form>
    
    <hr/>
    <h3>🗄️ Databases</h3>
    <%
        if (conn != null) {
            try {
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SHOW DATABASES");
                while (rs.next()) {
                    String db = rs.getString(1);
                    out.println("<a href='?selectedDb=" + db + "'>📁 " + db + "</a><br/>");
                }
                rs.close();
                stmt.close();
            } catch(Exception e) {
                out.println("<div class='error'>" + e.getMessage() + "</div>");
            }
        }
    %>
    
    <hr/>
    <h3>📋 Tables</h3>
    <%
        if (conn != null && selectedDb != null && !selectedDb.isEmpty()) {
            try {
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SHOW TABLES");
                while (rs.next()) {
                    String table = rs.getString(1);
                    String style = (selectedTable != null && selectedTable.equals(table)) ? "style='color:#4ecdc4; font-weight:bold;'" : "";
                    out.println("<a href='?selectedTable=" + table + "' " + style + ">📄 " + table + "</a><br/>");
                }
                rs.close();
                stmt.close();
            } catch(Exception e) {
                out.println("<div class='error'>" + e.getMessage() + "</div>");
            }
        }
    %>
</div>

<!-- Main Content -->
<div class="content">
    <%
        if (conn == null) {
            out.println("<div class='info'>🔌 Enter database credentials in sidebar to connect.</div>");
        } else if (selectedDb == null) {
            out.println("<div class='info'>🗄️ Select a database from sidebar.</div>");
        } else if (selectedTable == null) {
            out.println("<div class='info'>📋 Select a table from sidebar.</div>");
        } else {
            // Show table data
            try {
                Statement stmt = conn.createStatement();
                ResultSetMetaData meta = null;
                ResultSet rs = null;
                int cols = 0;
                
                // Get first column name as ID (for edit/delete)
                String firstColumn = "";
                ResultSet rsCol = stmt.executeQuery("SELECT * FROM " + selectedTable + " LIMIT 1");
                meta = rsCol.getMetaData();
                cols = meta.getColumnCount();
                firstColumn = meta.getColumnName(1);
                rsCol.close();
                
                // Get all data
                rs = stmt.executeQuery("SELECT * FROM " + selectedTable + " LIMIT 200");
                meta = rs.getMetaData();
                cols = meta.getColumnCount();
                
                out.println("<h2>Table: " + selectedTable + "</h2>");
                out.println("<div style='margin-bottom:10px;'>");
                out.println("<button onclick=\"document.getElementById('sqlText').value='SELECT * FROM " + selectedTable + "'\">📋 Show All</button>");
                out.println("<button onclick=\"if(confirm('Drop table " + selectedTable + "?')) window.location='?action=dropTable&selectedTable=" + selectedTable + "'\">⚠️ Drop Table</button>");
                out.println("</div>");
                
                out.println("<form method='get' id='editForm' style='display:none;'>");
                out.println("<input type='hidden' name='selectedTable' value='" + selectedTable + "'>");
                out.println("<input type='hidden' name='idColumn' value='" + firstColumn + "'>");
                out.println("</form>");
                
                out.println("<table border='1'>");
                out.println("<td>");
                for (int i = 1; i <= cols; i++) {
                    out.println("<th>" + meta.getColumnName(i) + "</th>");
                }
                out.println("<th>Actions</th>");
                out.println("</tr>");
                
                while (rs.next()) {
                    String rowId = rs.getString(1);
                    out.println("<tr>");
                    for (int i = 1; i <= cols; i++) {
                        String val = rs.getString(i);
                        out.println("<td>" + (val != null ? val : "NULL") + "</td>");
                    }
                    // Edit & Delete buttons
                    out.println("<td>");
                    out.println("<a href='#' onclick='showEdit(\"" + selectedTable + "\", \"" + rowId + "\", \"" + firstColumn + "\")'>✏️ Edit</a> | ");
                    out.println("<a href='?deleteId=" + rowId + "&selectedTable=" + selectedTable + "&idColumn=" + firstColumn + "' onclick='return confirm(\"Delete this row?\")'>🗑️ Delete</a>");
                    out.println("</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
                rs.close();
                stmt.close();
                
                // Show table structure
                out.println("<h3>📐 Table Structure</h3>");
                stmt = conn.createStatement();
                rs = stmt.executeQuery("DESCRIBE " + selectedTable);
                out.println("<table border='1'>");
                out.println("<tr><th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th><th>Extra</th></tr>");
                while (rs.next()) {
                    out.println("<tr>");
                    out.println("<td>" + rs.getString(1) + "</td>");
                    out.println("<td>" + rs.getString(2) + "</td>");
                    out.println("<td>" + rs.getString(3) + "</td>");
                    out.println("<td>" + rs.getString(4) + "</td>");
                    out.println("<td>" + (rs.getString(5) != null ? rs.getString(5) : "NULL") + "</td>");
                    out.println("<td>" + rs.getString(6) + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
                rs.close();
                stmt.close();
                
            } catch(Exception e) {
                out.println("<div class='error'>❌ Error: " + e.getMessage() + "</div>");
            }
        }
    %>
    
    <!-- Edit Modal (JavaScript popup) -->
    <div id="editModal" style="display:none; position:fixed; top:50%; left:50%; transform:translate(-50%,-50%); background:#2d2d2d; padding:20px; border-radius:10px; z-index:1000; border:2px solid #0d7377;">
        <h3>✏️ Edit Row</h3>
        <form method="get" id="editRowForm">
            <input type="hidden" name="selectedTable" id="editTable">
            <input type="hidden" name="editId" id="editId">
            <input type="hidden" name="idColumn" id="editIdColumn">
            <label>Column Name:</label><br/>
            <input type="text" name="editColumn" id="editColumn" style="width:100%"><br/><br/>
            <label>New Value:</label><br/>
            <input type="text" name="editValue" id="editValue" style="width:100%"><br/><br/>
            <button type="submit">💾 Save</button>
            <button type="button" onclick="document.getElementById('editModal').style.display='none'">Cancel</button>
        </form>
    </div>
    
    <script>
        function showEdit(table, id, idColumn) {
            document.getElementById('editTable').value = table;
            document.getElementById('editId').value = id;
            document.getElementById('editIdColumn').value = idColumn;
            document.getElementById('editModal').style.display = 'block';
        }
    </script>
    
    <hr/>
    
    <!-- SQL Editor -->
    <h3>📝 SQL Query (For Bulk Update/Insert/Delete)</h3>
    <form method="get">
        <input type="hidden" name="action" value="exec">
        <textarea name="sqlQuery" id="sqlText" rows="6" cols="100" style="background:#2d2d2d; color:#fff; font-family:monospace;"><%= sqlQuery != null ? sqlQuery : "" %></textarea><br/>
        <button type="submit">🚀 Execute</button>
        <button type="button" onclick="document.getElementById('sqlText').value='SELECT username, password FROM JIUser'">🔑 Get Users</button>
        <button type="button" onclick="document.getElementById('sqlText').value='SHOW TABLES'">📋 Show Tables</button>
        <button type="button" onclick="document.getElementById('sqlText').value='UPDATE JIUser SET password = MD5(\'admin123\') WHERE username = \'superuser\''">🔄 Reset superuser password</button>
        <button type="button" onclick="document.getElementById('sqlText').value='UPDATE JIUser SET enabled = 1 WHERE enabled = 0'">✅ Enable all users</button>
    </form>
</div>

<div class="clearfix"></div>
</body>
</html>
