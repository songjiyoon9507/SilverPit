package com.silverfitterpan.mobileweb.common.config;

import org.apache.catalina.connector.Connector;
import org.apache.tomcat.util.descriptor.web.SecurityCollection;
import org.apache.tomcat.util.descriptor.web.SecurityConstraint;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.tomcat.servlet.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * HTTP(80) 로 들어온 요청을 HTTPS(server.port, 보통 443) 로 리다이렉트.
 * - 서버 config.properties 에 app.http-redirect.enabled=true 일 때만 동작 (로컬은 꺼둠)
 * - server.port 는 HTTPS 포트, app.http-redirect.port 는 추가로 여는 HTTP 포트
 */
@Configuration
@ConditionalOnProperty(prefix = "app.http-redirect", name = "enabled", havingValue = "true")
public class HttpsRedirectConfig {

	@Bean
	public WebServerFactoryCustomizer<TomcatServletWebServerFactory> httpToHttpsRedirect(
			@Value("${app.http-redirect.port:80}") int httpPort,
			@Value("${server.port:443}") int httpsPort) {

		return factory -> {
			// 모든 경로(/*)를 CONFIDENTIAL(=HTTPS 필수)로 지정 -> HTTP 요청은 redirectPort 로 이동
			factory.addContextCustomizers(context -> {
				SecurityCollection collection = new SecurityCollection();
				collection.addPattern("/*");

				SecurityConstraint constraint = new SecurityConstraint();
				constraint.setUserConstraint("CONFIDENTIAL");
				constraint.addCollection(collection);

				context.addConstraint(constraint);
			});

			// HTTP 포트용 커넥터 추가
			Connector connector = new Connector(TomcatServletWebServerFactory.DEFAULT_PROTOCOL);
			connector.setScheme("http");
			connector.setPort(httpPort);
			connector.setSecure(false);
			connector.setRedirectPort(httpsPort);
			factory.addAdditionalConnectors(connector);
		};
	}
}
