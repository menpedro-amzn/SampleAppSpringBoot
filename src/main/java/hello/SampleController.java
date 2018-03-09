package hello;

import java.util.concurrent.atomic.AtomicLong;

import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.stereotype.*;
import org.springframework.web.bind.annotation.*;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import  java.util.Random;

@Controller
@EnableAutoConfiguration
public class SampleController {
  private static final String template = "Hello, %s!";
  //private final AtomicLong counter = new AtomicLong();

  long generateSecretToken() {
      Random r = new Random();
      return r.nextLong();
  }

  @RequestMapping("/")
  public @ResponseBody Greeting sayHello(@RequestParam(value="name", required=false, defaultValue="Stranger") String name) {
      //return new Greeting(counter.incrementAndGet(), String.format(template, name));
      return new Greeting(generateSecretToken(), String.format(template, name));
  }

  public static void main(String[] args) throws Exception {
      SpringApplication.run(SampleController.class, args);
  }
}
