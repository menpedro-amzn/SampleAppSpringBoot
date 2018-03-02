package ok

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class SampleAppSpringBootTest extends Simulation {

  val httpConf = http
    .baseURL("http://myspringboot-111930942.us-east-1.elb.amazonaws.com")
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    .doNotTrackHeader("1")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0")

  val scn = scenario("Simple")
    .exec(http("Stranger")
      .get("/")
      .check(status.is(200), jsonPath("$.content").exists))

  setUp(scn.inject(constantUsersPerSec(200) during(3 minutes)))
    .protocols(httpConf)
    .assertions(
      forAll.failedRequests.percent.is(0),
      global.responseTime.percentile3.lt(1000)
    )
}
