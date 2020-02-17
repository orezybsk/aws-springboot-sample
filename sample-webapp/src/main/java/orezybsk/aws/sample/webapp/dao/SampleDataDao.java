package orezybsk.aws.sample.webapp.dao;

import orezybsk.aws.sample.webapp.entity.SampleData;
import orezybsk.aws.sample.webapp.util.doma.ComponentAndAutowiredDomaConfig;
import org.seasar.doma.*;

import java.util.List;

/**
 * sample_data テーブル用 Dao インターフェース
 */
@Dao
@ComponentAndAutowiredDomaConfig
public interface SampleDataDao {

    /**
     * @param id ID
     * @return the SampleData entity
     */
    @Select
    SampleData selectById(Long id);

    /**
     * データ一覧を取得する
     *
     * @return SampleData 一覧
     */
    @Select
    List<SampleData> selectAll();

    /**
     * @param entity the SampleData entity
     * @return affected rows
     */
    @Insert
    int insert(SampleData entity);

    /**
     * @param entity the SampleData entity
     * @return affected rows
     */
    @Update
    int update(SampleData entity);

    /**
     * @param entity the SampleData entity
     * @return affected rows
     */
    @Delete
    int delete(SampleData entity);
}