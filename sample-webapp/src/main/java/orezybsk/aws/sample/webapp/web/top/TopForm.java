package orezybsk.aws.sample.webapp.web.top;

import lombok.Data;
import orezybsk.aws.sample.webapp.entity.SampleData;

import java.util.List;

/**
 * トップ画面用 Form クラス
 */
@Data
public class TopForm {

    private List<SampleData> sampleDataList;

}
