# NuGet restore
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY *.sln .
COPY tests/*.csproj tests/
COPY aspnetcore3/*.csproj aspnetcore3/
RUN dotnet restore
COPY . .

# testing
FROM build AS testing
WORKDIR /src/aspnetcore3
RUN dotnet build
WORKDIR /src/tests
RUN dotnet test

# publish
FROM build AS publish
WORKDIR /src/aspnetcore3
RUN dotnet publish -c Release -o /src/publish

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS runtime
WORKDIR /app
COPY --from=publish /src/publish .
# ENTRYPOINT ["dotnet", "Colors.API.dll"]
# heroku uses the following
CMD ASPNETCORE_URLS=http://*:$PORT dotnet aspnetcore3.dll