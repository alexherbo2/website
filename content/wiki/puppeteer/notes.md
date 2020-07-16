---
title: Puppeteer Notes
description: First experiment with Puppeteer
date: 2020-05-11
---

{{< table-of-contents >}}

## Links

- https://pptr.dev
- https://github.com/puppeteer/puppeteer
- https://npmjs.com/package/puppeteer
- https://github.com/puppeteer/puppeteer/blob/master/docs/api.md

## Videos

- [Web Scraping With NodeJS and Puppeteer](https://youtu.be/ARt3zDHSsd4)
- [The power of Headless Chrome and browser automation (Google I/O '18)](https://youtu.be/lhZOFUY1weo)
- [Scraping Reddit with Puppeteer & NodeJs](https://youtu.be/o7MJ1-UhS50)

## Example

Scrape [Chrome APIs]:

[Chrome APIs]: https://developer.chrome.com/extensions/api_index

`package.json`

``` json
{
  "dependencies": {
    "puppeteer": "^5.1.0"
  }
}
```

`scraper.js`

``` javascript
const puppeteer = require('puppeteer')
const fs = require('fs')

const main = async () => {
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  const index = []

  await page.goto('https://developer.chrome.com/extensions/api_index')
  const pageURLs = await page.$$eval('main table:first-of-type tr td:first-child a', (links) => links.map((link) => link.href))
  for (const pageURL of pageURLs) {
    console.log(pageURL)
    await page.goto(pageURL)
    const api = await page.$eval('h1', (title) => title.textContent)
    const records = await page.evaluate((api) => {
      const capitalize = (text) => {
        return text.charAt(0).toUpperCase() + text.slice(1)
      }
      const nodeList = document.querySelectorAll('table.api-summary tr td a')
      const records = Array.from(nodeList, (link) => {
        const name = link.textContent
        const type = capitalize(link.hash.match(/#([a-z]+)/)[1])
        const url = link.href
        const objectID = url
        return { objectID, name, type, api, url }
      })
      return records
    }, api)
    console.log(records)
    index.push(...records)
  }
  await fs.writeFile('index.json', JSON.stringify(index, undefined, 2), (error) => {})

  await browser.close()
}

main()
```

`Makefile`

``` makefile
install:
	npm install

scrape: install
	node scraper.js

clean:
	rm -Rf index.json node_modules package-lock.json
```

`.gitignore`

```
index.json
node_modules
package-lock.json
```

## Snippets

### Headless

``` javascript
const browser = await puppeteer.launch({
  headless: false
})
```

### Log in

``` javascript
await page.focus('#username')
await page.keyboard.type(config.username)
await page.focus('#password')
await page.keyboard.type(config.password)
await page.click('#log-in')
```

### Evaluate

**Note**: The return value must be serializable.

``` javascript
const result = await page.evaluate(() => {
  const elements = document.querySelectorAll('.item')
  const items = Array.from(elements).map((element) => {
    const property = {
      url: element.href,
      description: element.textContent
    }
    return property
  })
  return items
})
```

Shortcut to [`document.querySelectorAll`]:

``` javascript
const result = await page.$$eval('.item', (elements) => {
  const items = elements.map((element) => {
    const property = {
      url: element.href,
      description: element.textContent
    }
    return property
  })
  return items
})
```

See also:

- `$eval`: Same as `$$eval`, but with [`document.querySelector`].

Intermediate results:

``` javascript
const elements = await page.$$('.item')
const items = []

for (const element of elements) {
  const url = await element.evaluate((element) => element.href)
  const description = await element.evaluate((element) => element.textContent)
  const property = { url, description }
  items.push(property)
}
```

See also:

- `$`: Same as `$$`, but with [`document.querySelector`].

### Waiting for something

``` javascript
await page.waitForSelector('#something-taking-time-to-appear')
```

``` javascript
await page.waitFor(() => {
  return document.querySelector('#something') !== null
})
```

[`document.querySelector`]: https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector
[`document.querySelectorAll`]: https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelectorAll
