using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace src
{
    public class http
    {
        private readonly ILogger _logger;

        public http(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<http>();
        }

        [Function("http")]
        public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            
            var files = Directory.GetFiles("/test-share");


            // string message;
            // var task = IsConnectedAsync();

            // if (await Task.WhenAny(task, Task.Delay(5000)) == task)
            // {
            //     message = "Connected";
            // }
            // else
            // {
            //     message = "5s timeout reached";
            // }

            response.WriteString($"Welcome to Azure Functions! = {string.Join(',', files)}");
            return response;
        }

        private async Task<bool> IsConnectedAsync() 
        {
            using(var tcpClient = new TcpClient())
            {
                try
                {
                    await tcpClient.ConnectAsync("qi1jmjyeap0.file.core.windows.net.net", 445);
                    return true;
                }
                catch
                {
                    return false;
                }
            }
        }
    }
}
