package orezybsk.aws.sample.webapp.security;

import lombok.Data;
import orezybsk.aws.sample.webapp.entity.UserInfo;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;

/**
 * ユーザ情報
 */
@Data
public class WebappUser implements Serializable {

    private static final long serialVersionUID = -6136686206972993318L;

    String email;

    String password;

    /**
     * コンストラクタ
     *
     * @param userInfo {@UserInfo} オブジェクト
     */
    public WebappUser(UserInfo userInfo) {
        BeanUtils.copyProperties(userInfo, this);
    }

}
