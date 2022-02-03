using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Fitability.ApiApp.Configurations;

using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Configurations.AppSettings.Extensions;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Configurations;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(Fitability.ApiApp.Startup))]

namespace Fitability.ApiApp
{
    public class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            builder.ConfigurationBuilder
                   .AddEnvironmentVariables();

            base.ConfigureAppConfiguration(builder);
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
            this.ConfigureAppSettings(builder.Services);
            this.ConfigureHttpClient(builder.Services);
        }

        private void ConfigureAppSettings(IServiceCollection services)
        {
            var userApiSettings = services.BuildServiceProvider()
                                          .GetService<IConfiguration>()
                                          .Get<UserApiSettings>(UserApiSettings.Name);

            services.AddSingleton(userApiSettings);
        }

        private void ConfigureHttpClient(IServiceCollection services)
        {
            services.AddHttpClient();
        }
    }
}