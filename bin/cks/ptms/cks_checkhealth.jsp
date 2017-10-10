<%@ page 
language="java" contentType="text/html; charset=UTF-8" 
pageEncoding="UTF-8"
import="java.net.InetAddress"
import="java.net.NetworkInterface"
import="java.net.SocketException"
import="java.util.ArrayList"
import="java.util.Enumeration"
import="java.util.List"
import="java.text.SimpleDateFormat"
import="java.util.*"
%> 
<body>
    <%out.println("health check page<br>");
    List<String> res=new ArrayList<String>();
    Enumeration netInterfaces;
    try {
    netInterfaces = NetworkInterface.getNetworkInterfaces();
    InetAddress ip = null;
    labelA:
    while (netInterfaces.hasMoreElements()) {
    NetworkInterface ni = (NetworkInterface) netInterfaces.nextElement();
    Enumeration nii=ni.getInetAddresses();
    while(nii.hasMoreElements()){
    ip = (InetAddress) nii.nextElement();
    if (ip.getHostAddress().indexOf(":") == -1) {
    res.add(ip.getHostAddress());
    out.println("ip=" + ip.getHostAddress());
    }
    }
    }
    } catch (SocketException e) {
    e.printStackTrace();
    }
    out.println("<br>");
    String aa = new SimpleDateFormat( "yyyy-MM-dd HH:mm:ss ").format(new Date());
    out.println(aa); 
    out.println("<br>");
    double total = (Runtime.getRuntime().totalMemory()) / (1024.0 * 1024);
    double max = (Runtime.getRuntime().maxMemory()) / (1024.0 * 1024);
    double free = (Runtime.getRuntime().freeMemory()) / (1024.0 * 1024);
    out.println("max=" + max + " total=" + total + " free=" + free);
    %>
</body>
