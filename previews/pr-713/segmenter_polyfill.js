if (typeof Intl !== 'undefined' && Intl.Segmenter && !Intl.v8BreakIterator) {
  Intl.v8BreakIterator = function (locale, options) {
    const segmenter = new Intl.Segmenter(locale, options);
    let segments = [];
    let index = 0;
    return {
      adoptText(text) {
        segments = Array.from(segmenter.segment(text), s => s.index);
        segments.push(text.length);
        index = 0;
      },
      first() {
        index = 0;
        return segments[0] ?? -1;
      },
      next() {
        index++;
        return index < segments.length ? segments[index] : -1;
      },
      current() {
        return index < segments.length ? segments[index] : -1;
      },
    };
  };
}
