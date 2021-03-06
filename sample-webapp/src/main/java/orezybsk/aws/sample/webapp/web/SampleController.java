package orezybsk.aws.sample.webapp.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * サンプル画面用 Controller クラス
 */
@Controller
@RequestMapping("/sample")
public class SampleController {

    /**
     * 初期表示処理
     *
     * @return Thymeleaf テンプレートを示す文字列
     */
    @GetMapping
    @ResponseBody
    public String index() {
        return "sample";
    }

}
