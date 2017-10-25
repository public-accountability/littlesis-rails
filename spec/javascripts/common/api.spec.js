describe('API module', () => {

  // TODO: (ag|24-Oct-2017) extract this to a support file somewhere?
  const responseOf = (obj) => Promise.resolve(
    new Response(JSON.stringify(obj)),
    { status: 200 }
  );

    // retrieved as logged in user from running dev server on 23-Oct-2017
    const wmSearchResults = [
      {
        id:            1,
        name:         "Walmart",
        description:  "Retail merchandising and union busting",
        primary_type: "Org",
        url:          "/org/1/Walmart"
      },
      {
        id:           77304,
        name:         "The Walmart Foundation",
        description:  "Wal-Mart foundation",
        primary_type: "Org",
        url:          "/org/77304/The_Walmart_Foundation"
      },
      {
        id:           106423,
        name:         "Walmart Stores U.S",
        description:  "Largest division of Walmart Stores, Inc.",
        primary_type: "Org",
        url:          "/org/106423/Walmart_Stores_U.S"}
    ];

    const formattedWmSearchResults = [
      {
        id:            1,
        name:         "Walmart",
        description:  "Retail merchandising and union busting",
        primary_ext: "Org",
        url:          "/org/1/Walmart"
      },
      {
        id:           77304,
        name:         "The Walmart Foundation",
        description:  "Wal-Mart foundation",
        primary_ext: "Org",
        url:          "/org/77304/The_Walmart_Foundation"
      },
      {
        id:           106423,
        name:         "Walmart Stores U.S",
        description:  "Largest division of Walmart Stores, Inc.",
        primary_ext: "Org",
        url:          "/org/106423/Walmart_Stores_U.S"}
    ];

  describe('#searchEntity', () => {

    it('resolves a promise of well-formatted entities on successful search', done => {
      spyOn(window, 'fetch').and.returnValue(responseOf(wmSearchResults));
      api.searchEntity('walmart').then((res => {
        expect(res).toEqual(formattedWmSearchResults);
        done();
      }));
    });

    it('resovles a promise of an empty array on failed search', done => {
      spyOn(window, 'fetch').and.returnValue(Promise.reject("Intentionally-created error for tests."));

      api.searchEntity('walmart').then(res => {
        expect(res).toEqual([]);
        done();
      });
    });
  });
});
