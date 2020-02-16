package orezybsk.aws.sample.webapp.security;

import orezybsk.aws.sample.webapp.dao.UserInfoDao;
import orezybsk.aws.sample.webapp.dao.UserRoleDao;
import orezybsk.aws.sample.webapp.entity.UserInfo;
import orezybsk.aws.sample.webapp.entity.UserRole;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * ???
 */
@Service
public class WebappUserDetailsService implements UserDetailsService {

    private final UserInfoDao userInfoDao;

    private final UserRoleDao userRoleDao;

    private final MessageSource messageSource;

    /**
     * @param userInfoDao   ???
     * @param userRoleDao   ???
     * @param messageSource ???
     */
    public WebappUserDetailsService(UserInfoDao userInfoDao
            , UserRoleDao userRoleDao
            , MessageSource messageSource) {
        this.userInfoDao = userInfoDao;
        this.userRoleDao = userRoleDao;
        this.messageSource = messageSource;
    }

    @Override
    public UserDetails loadUserByUsername(String email) {
        UserInfo userInfo = userInfoDao.selectById(email);
        if (userInfo == null) {
            throw new UsernameNotFoundException(
                    messageSource.getMessage("UserInfoUserDetailsService.usernameNotFound"
                            , null, LocaleContextHolder.getLocale()));
        }

        Set<SimpleGrantedAuthority> authorities = new HashSet<>();
        List<UserRole> userRoleList = userRoleDao.selectByEmail(userInfo.getEmail());
        if (userRoleList != null) {
            authorities.addAll(
                    userRoleList.stream()
                            .map(userRole -> new SimpleGrantedAuthority(userRole.getRole()))
                            .collect(Collectors.toList()));
        }

        return new WebappUserDetails(userInfo, authorities);
    }

}
