package orezybsk.aws.sample.webapp.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.DefaultAuthenticationEventPublisher;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

/**
 * Spring Security 設定用 Configuration クラス
 */
@Lazy(false)
@Configuration
public class WebSecurityConfig {

    private final UserDetailsService userDetailsService;


    /**
     * コンストラクタ
     *
     * @param userDetailsService {@UserDetailsService} bean
     */
    public WebSecurityConfig(@Qualifier("webappUserDetailsService") UserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    /**
     * 認証が不要な URL の定義と、Form 認証に関する設定を行う
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
                    .antMatchers("/html/**").permitAll()
                    .antMatchers("/vendor/**").permitAll()
                    .anyRequest().hasAnyRole("USER");

            http.formLogin()
                    .loginPage("/")
                    .loginProcessingUrl("/login")
                    .defaultSuccessUrl("/sample")
                    .usernameParameter("email")
                    .passwordParameter("password")
                    .permitAll()
                    .and()
                    .logout()
                    .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))
                    .logoutSuccessUrl("/")
                    .deleteCookies("SESSION")
                    .invalidateHttpSession(true)
                    .permitAll();
        }

    }

    /**
     * 認証処理を設定する
     *
     * @param auth                      {@link AuthenticationManagerBuilder} bean
     * @param applicationEventPublisher {@link ApplicationEventPublisher} bean
     * @throws Exception ???
     */
    @SuppressWarnings("PMD.SignatureDeclareThrowsException")
    @Autowired
    public void configAuthentication(AuthenticationManagerBuilder auth
            , ApplicationEventPublisher applicationEventPublisher) throws Exception {
        auth.authenticationEventPublisher(new DefaultAuthenticationEventPublisher(applicationEventPublisher))
                .userDetailsService(userDetailsService);
    }

}
