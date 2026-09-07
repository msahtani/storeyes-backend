package io.storeyes.storeyes_coffee.config;

import org.apache.catalina.connector.Connector;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Adds a plain HTTP connector next to the primary connector so the API is reachable
 * over both http://host:${server.http.port} and https://host:${server.port}.
 *
 * Only registered when SSL is on: with ssl.enabled=false the primary connector is
 * already plain HTTP, and a second connector on the same port would fail to bind.
 */
@Configuration
public class HttpConnectorConfig {

    @Value("${server.http.port:8080}")
    private int httpPort;

    @Value("${server.port:8443}")
    private int httpsPort;

    @Value("${server.ssl.enabled:true}")
    private boolean sslEnabled;

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> httpConnectorCustomizer() {
        return factory -> {
            if (!sslEnabled || httpPort <= 0 || httpPort == httpsPort) {
                return;
            }
            Connector connector = new Connector(TomcatServletWebServerFactory.DEFAULT_PROTOCOL);
            connector.setScheme("http");
            connector.setSecure(false);
            connector.setPort(httpPort);
            factory.addAdditionalTomcatConnectors(connector);
        };
    }
}
