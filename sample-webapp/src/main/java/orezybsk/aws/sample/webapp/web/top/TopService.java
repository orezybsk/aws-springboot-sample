package orezybsk.aws.sample.webapp.web.top;

import orezybsk.aws.sample.webapp.dao.SampleDataDao;
import org.springframework.stereotype.Service;

/**
 * トップ画面用 Service クラス
 */
@Service
public class TopService {

    private final SampleDataDao sampleDataDao;

    /**
     * コンストラクタ
     *
     * @param sampleDataDao {@link SampleDataDao} bean
     */
    public TopService(SampleDataDao sampleDataDao) {
        this.sampleDataDao = sampleDataDao;
    }

    /**
     * sample_data テーブルのデータ一覧を取得する
     *
     * @param topForm {@link TopForm} オブジェクト
     */
    public void selectSampleData(TopForm topForm) {
        topForm.setSampleDataList(sampleDataDao.selectAll());
    }

}
