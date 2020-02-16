package orezybsk.aws.sample.webapp.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * ログイン画面用 Controller クラス
 */
@Controller
@RequestMapping("/")
public class LoginController {

    /**
     * 初期表示処理
     *
     * @return Thymeleaf テンプレートを示す文字列
     */
    @GetMapping
    public String index() {
        return "web/login";
    }

}
