package orezybsk.aws.sample.webapp.dao;

import orezybsk.aws.sample.webapp.entity.UserInfo;
import orezybsk.aws.sample.webapp.util.doma.ComponentAndAutowiredDomaConfig;
import org.seasar.doma.*;

/**
 * user_info テーブル用 Dao インターフェース
 */
@Dao
@ComponentAndAutowiredDomaConfig
public interface UserInfoDao {

    /**
     * @param email メールアドレス
     * @return the UserInfo entity
     */
    @Select
    UserInfo selectById(String email);

    /**
     * @param entity the UserInfo entity
     * @return affected rows
     */
    @Insert
    int insert(UserInfo entity);

    /**
     * @param entity the UserInfo entity
     * @return affected rows
     */
    @Update
    int update(UserInfo entity);

    /**
     * @param entity the UserInfo entity
     * @return affected rows
     */
    @Delete
    int delete(UserInfo entity);
}