package orezybsk.aws.sample.webapp.web.top;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * トップ画面用 Controller クラス
 */
@Controller
@RequestMapping("/top")
public class TopController {

    private final TopService topService;

    /**
     * コンストラクタ
     *
     * @param topService {@link TopService} bean
     */
    public TopController(TopService topService) {
        this.topService = topService;
    }

    /**
     * 初期表示処理
     *
     * @param topForm {@link TopForm} オブジェクト
     * @return Thymeleaf テンプレートを示す文字列
     */
    @GetMapping
    public String index(TopForm topForm) {
        topService.selectSampleData(topForm);
        return "web/top/index";
    }

}
