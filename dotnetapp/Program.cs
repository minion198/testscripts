using System;
using System.Net;
using System.Text;
using System.Net.Sockets;

class Program
{
    static void Main()
    {
        HttpListener listener = new HttpListener();
        listener.Prefixes.Add("http://*:8080/");
        listener.Start();
        Console.WriteLine("Sample App Running on port 8080...");

        while (true)
        {
            HttpListenerContext context = listener.GetContext();
            HttpListenerResponse response = context.Response;

            // Get VM IP Address and Hostname
            string hostname = Dns.GetHostName();
            string ipAddress = GetLocalIPAddress();

            string responseString = $"Immutable Infrastructure POC Running!\nVM Hostname: {hostname}\nVM IP: {ipAddress}";
            byte[] buffer = Encoding.UTF8.GetBytes(responseString);
            response.ContentLength64 = buffer.Length;
            response.OutputStream.Write(buffer, 0, buffer.Length);
            response.OutputStream.Close();
        }
    }

    // Get the local IP address of the VM
    static string GetLocalIPAddress()
    {
        foreach (var ip in Dns.GetHostAddresses(Dns.GetHostName()))
        {
            if (ip.AddressFamily == AddressFamily.InterNetwork)
            {
                return ip.ToString();
            }
        }
        return "Unknown";
    }
}
