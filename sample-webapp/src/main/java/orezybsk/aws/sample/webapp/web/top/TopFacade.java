package orezybsk.aws.sample.webapp.web.top;

import orezybsk.aws.sample.webapp.service.SampleDataService;
import org.springframework.stereotype.Service;

/**
 * トップ画面用 Facade クラス
 */
@Service
public class TopFacade {

    private final SampleDataService sampleDataService;

    /**
     * コンストラクタ
     *
     * @param sampleDataService {@link SampleDataService} bean
     */
    public TopFacade(SampleDataService sampleDataService) {
        this.sampleDataService = sampleDataService;
    }

    /**
     * sample_data テーブルのデータ一覧を取得する
     *
     * @param topForm {@link TopForm} オブジェクト
     */
    public void selectSampleData(TopForm topForm) {
        topForm.setSampleDataList(sampleDataService.selectAll());
    }

}
