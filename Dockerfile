FROM node:18-alpine
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
az acr login --name <your_registry_name>
docker tag your-app <your_registry_name>.azurecr.io/your-app
docker push <your_registry_name>.azurecr.io/your-app
trigger:
    - main
  
  variables:
    imageName: your-app
  
  stages:
    - stage: Build
      jobs:
        - job: BuildAndPush
          pool:
            vmImage: 'ubuntu-latest'
          steps:
            - task: Docker@2
              inputs:
                command: buildAndPush
                repository: $(imageName)
                dockerfile: '/Dockerfile'
                containerRegistry: '<your_service_connection_to_ACR>'
                tags: latest
  
    - stage: Deploy
      jobs:
        - deployment: DeployWebApp
          environment: 'production'
          pool:
            vmImage: 'ubuntu-latest'
          strategy:
            runOnce:
              deploy:
                steps:
                  - task: AzureWebAppContainer@1
                    inputs:
                      azureSubscription: '<your_service_connection_to_azure>'
                      appName: '<your_app_service_name>'
                      containers: '<your_registry_name>.azurecr.io/your-app:latest'