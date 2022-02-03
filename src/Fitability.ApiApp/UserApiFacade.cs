using System.IO;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;

using Aliencube.AzureFunctions.Extensions.Common;

using Fitability.ApiApp.Configurations;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Extensions;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;

using Newtonsoft.Json;

namespace Fitability.ApiApp
{
    public class UserApiFacade
    {
        private readonly UserApiSettings _settings;
        private readonly HttpClient _http;
        private readonly ILogger<UserApiFacade> _logger;

        public UserApiFacade(UserApiSettings settings, HttpClient http, ILogger<UserApiFacade> log)
        {
            this._settings = settings.ThrowIfNullOrDefault();
            this._http = http.ThrowIfNullOrDefault();
            this._logger = log.ThrowIfNullOrDefault();
        }

        [FunctionName(nameof(UserApiFacade.MeAsync))]
        [OpenApiOperation(operationId: "users.me", tags: new[] { "me" })]
        [OpenApiParameter(name: "name", In = ParameterLocation.Query, Required = true, Type = typeof(string), Description = "The **Name** parameter")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: ContentTypes.PlainText, bodyType: typeof(string), Description = "The OK response")]
        public async Task<IActionResult> MeAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, HttpVerbs.GET, Route = "me")] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            var apiKey = this._settings.ApiKey;

            string name = req.Query["name"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            name = name ?? data?.name;

            string responseMessage = string.IsNullOrEmpty(name)
                ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                : $"Hello, {name}. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }
    }
}