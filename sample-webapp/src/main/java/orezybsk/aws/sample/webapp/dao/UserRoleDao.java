package orezybsk.aws.sample.webapp.dao;

import orezybsk.aws.sample.webapp.entity.UserRole;
import orezybsk.aws.sample.webapp.util.doma.ComponentAndAutowiredDomaConfig;
import org.seasar.doma.*;

import java.util.List;

/**
 * user_role テーブル用 Dao インターフェース
 */
@Dao
@ComponentAndAutowiredDomaConfig
public interface UserRoleDao {

    /**
     * @param roleId ロールID
     * @return the UserRole entity
     */
    @Select
    UserRole selectById(Long roleId);

    /**
     * email の role 一覧を取得する
     *
     * @param email メールアドレス
     * @return {@UserRole} データ一覧
     */
    @Select
    List<UserRole> selectByEmail(String email);

    /**
     * @param entity the UserRole entity
     * @return affected rows
     */
    @Insert
    int insert(UserRole entity);

    /**
     * @param entity the UserRole entity
     * @return affected rows
     */
    @Update
    int update(UserRole entity);

    /**
     * @param entity the UserRole entity
     * @return affected rows
     */
    @Delete
    int delete(UserRole entity);
}