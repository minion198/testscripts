using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

public class Program
{
    public static void Main(string[] args)
    {
        Host.CreateDefaultBuilder(args)
            .UseWindowsService()
            .ConfigureServices(services =>
            {
                services.AddHostedService<HttpServerService>();
            })
            .Build()
            .Run();
    }
}

public class HttpServerService : BackgroundService
{
    private readonly ILogger<HttpServerService> _logger;

    public HttpServerService(ILogger<HttpServerService> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        HttpListener listener = new HttpListener();
        listener.Prefixes.Add("http://*:8080/");
        listener.Start();
        _logger.LogInformation("Sample App Running as Windows Service on port 8080...");

        while (!stoppingToken.IsCancellationRequested)
        {
            HttpListenerContext context = await listener.GetContextAsync();
            HttpListenerResponse response = context.Response;

            string hostname = Dns.GetHostName();
            string ipAddress = GetLocalIPAddress();

            string responseString = $"Immutable Infrastructure POC Running!\nVM Hostname: {hostname}\nVM IP: {ipAddress}";
            byte[] buffer = Encoding.UTF8.GetBytes(responseString);
            response.ContentLength64 = buffer.Length;
            await response.OutputStream.WriteAsync(buffer, 0, buffer.Length, stoppingToken);
            response.OutputStream.Close();
        }

        listener.Stop();
    }

    private string GetLocalIPAddress()
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
