package orezybsk.aws.sample.webapp.config;

import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

/**
 * Spring Security 設定用 Configuration クラス
 */
@Lazy(false)
@Configuration
public class WebSecurityConfig {

    /**
     * ???
     */
    @Configuration
    public static class FormLoginWebSecurityConfigurationAdapter extends WebSecurityConfigurerAdapter {

        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.authorizeRequests()
                    // 認証の対象外にしたいURLがある場合には、以下のような記述を追加します
                    // 複数URLがある場合はantMatchersメソッドにカンマ区切りで対象URLを複数列挙します
                    // .antMatchers("/country/**").permitAll()
                    .requestMatchers(PathRequest.toStaticResources().atCommonLocations()).permitAll()
                    .antMatchers("/sample/**").permitAll()
                    .anyRequest().hasAnyRole("USER");
        }

    }

}
