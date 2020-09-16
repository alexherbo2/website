---
title: Puppeteer Notes
description: First experiment with Puppeteer
date: 2020-05-11
---

{{< table-of-contents >}}

## Repository

- [puppeteer-experiments]

[puppeteer-experiments]: https://github.com/alexherbo2/puppeteer-experiments

## Links

- https://pptr.dev
- https://github.com/puppeteer/puppeteer
- https://npmjs.com/package/puppeteer
- https://github.com/puppeteer/puppeteer/blob/master/docs/api.md

## Videos

- [Web Scraping With NodeJS and Puppeteer](https://youtu.be/ARt3zDHSsd4)
- [The power of Headless Chrome and browser automation (Google I/O '18)](https://youtu.be/lhZOFUY1weo)
- [Scraping Reddit with Puppeteer & NodeJs](https://youtu.be/o7MJ1-UhS50)

## Examples

See [puppeteer-experiments].

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
