package orezybsk.aws.sample.webapp.service;

import orezybsk.aws.sample.webapp.dao.SampleDataDao;
import orezybsk.aws.sample.webapp.entity.SampleData;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * sample_data テーブル用 Service クラス
 */
@Service
public class SampleDataService {

    private final SampleDataDao sampleDataDao;

    /**
     * コンストラクタ
     *
     * @param sampleDataDao {@link SampleDataDao} bean
     */
    public SampleDataService(SampleDataDao sampleDataDao) {
        this.sampleDataDao = sampleDataDao;
    }

    /**
     * sample_data テーブルのデータ一覧を取得する
     *
     * @return {@link SampleData} データ一覧
     */
    @Cacheable("dbCache")
    public List<SampleData> selectAll() {
        return sampleDataDao.selectAll();
    }

}
