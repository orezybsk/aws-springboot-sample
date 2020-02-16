package orezybsk.aws.sample.webapp.security;

import orezybsk.aws.sample.webapp.entity.UserInfo;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Set;

/**
 * ???
 */
public class WebappUserDetails implements UserDetails {

    private static final long serialVersionUID = 7586023899059696930L;

    private final WebappUser webappUser;

    private final Set<? extends GrantedAuthority> authorities;

    /**
     * @param userInfo    ???
     * @param authorities ???
     */
    public WebappUserDetails(UserInfo userInfo
            , Set<? extends GrantedAuthority> authorities) {
        this.webappUser = new WebappUser(userInfo);
        this.authorities = authorities;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getUsername() {
        return webappUser.getEmail();
    }

    @Override
    public String getPassword() {
        return webappUser.getPassword();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

}
