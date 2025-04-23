FROM debian:latest AS build-env

# Instalar ferramentas e dependências
RUN apt-get update 
RUN apt-get install -y curl git unzip

# Definir variáveis de ambiente
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

# Obter Flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
RUN flutter channel stable
RUN flutter upgrade
RUN flutter doctor

# Copiar arquivos do projeto
COPY . /app/
WORKDIR /app/

# Obter dependências e criar build Web
RUN flutter pub get
RUN flutter build web --release

# Preparar ambiente de produção com Nginx
FROM nginx:stable
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expor porta 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"] 