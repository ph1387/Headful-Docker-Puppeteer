const assert = require("assert");
const puppeteer = require("puppeteer");

let browser;
let page;

before(async () => {
  browser = await puppeteer.launch({
    // Use maximum available resolution.
    defaultViewport: null,
    // Use the fake display.
    headless: false,
    // Use the actual chrome installation.
    executablePath: "/usr/bin/google-chrome-unstable",

    args: [
      // Required for Docker version of Puppeteer.
      "--no-sandbox",
      "--disable-setuid-sandbox",
      // This will write shared memory files into /tmp instead of /dev/shm,
      // because Docker’s default for /dev/shm is 64MB.
      "--disable-dev-shm-usage",
      
      // Size of the fake display when starting chrome.
      "--window-size=1024,768"
    ]
  })

  const browserVersion = await browser.version();
  console.log(`Started ${browserVersion}`);
});

beforeEach(async () => {
  page = await browser.newPage();

  // Prevent certain pages from not delivering the content 
  // i.e. videos, images etc.
  page.setUserAgent("Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25");

  // Simple tags for formatting the output.
  const tagIndentation = "    ";
  const tagError = tagIndentation + "ERROR ";
  const tagRequest = tagIndentation + "REQUEST ";
  const tagResponse = tagIndentation + "RESPONSE ";

  await page.on("error", err => {
    console.error(tagError + "err: " + err);
  });

  await page.on("pageerror", pageerr => {
    console.error(tagError + "pageerr: " + pageerr);
  });

  await page.on("requestfailed", rf => {
    console.error(tagError + "requestfailed: " + rf);
  });

  await page.on("request", (request) => {
    console.log(tagRequest + request.url());
  });

  await page.on("response", response => {
    const url = response.url();

    response.buffer().then(
      buffer => {
        if (response.status() != 200) {
          console.log(tagResponse + url + " : " + response.status());
        }
      },
      error => {
        console.error(tagResponse + "ERROR " + url + " : " + response.status());
      }
    );
  });
})

afterEach(async () => {
  await page.close();
});

after(async () => {
  await browser.close();
});

describe("App", () => {
  it("Example", async function () {
    // Overwrite default mocha test execution time of 2s.
    this.timeout(60000);

    // Example for starting a video.
    await page.goto("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
    await page.waitFor(1000);
    await page.screenshot({ path: "/screenshots/001_video_stopped.png" });
    await page.waitFor("#player");
    await page.click("#player");
    await page.waitFor(1000);
    await page.screenshot({ path: "/screenshots/002_video_started.png" });
  });
});