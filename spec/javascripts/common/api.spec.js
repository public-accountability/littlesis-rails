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
        id:          "1",
        name:        "Walmart",
        blurb:       "Retail merchandising and union busting",
        primary_ext: "Org",
        url:         "/org/1/Walmart"
      },
      {
        id:          "77304",
        name:        "The Walmart Foundation",
        blurb:       "Wal-Mart foundation",
        primary_ext: "Org",
        url:         "/org/77304/The_Walmart_Foundation"
      },
      {
        id:          "106423",
        name:        "Walmart Stores U.S",
        blurb:       "Largest division of Walmart Stores, Inc.",
        primary_ext: "Org",
        url:         "/org/106423/Walmart_Stores_U.S"}
    ];

  var wmApiJson = {
    "meta": {
      "copyright": "LittleSis CC BY-SA 3.0",
      "license": "https://creativecommons.org/licenses/by-sa/3.0/us/",
      "apiVersion": "2.0-beta"
    },
    "data": {
      "type": "entities",
      "id": 1,
      "attributes": {
        "id": 1,
        "name": "Walmart",
        "blurb": "Retail merchandising and union busting",
        "summary": null,
        "website": "http://www.walmartstores.com",
        "parent_id": null,
        "primary_ext": "Org",
        "updated_at": "2017-10-12T18:38:26Z",
        "start_date": null,
        "end_date": null,
        "aliases": [
          "IRS EIN 71-0415188",
          "Wal Mart",
          "Wal-Mart",
          "Wal-Mart Stores Inc",
          "Wal-Mart Stores, Inc.",
          "Walmart"
        ],
        "types": [
          "Organization",
          "Business",
          "Public Company"
        ],
        "extensions": {
          "Org": {
            "name": "Wal-Mart Stores, Inc.",
            "name_nick": null,
            "employees": null,
            "revenue": 378799000000,
            "fedspending_id": "336092",
            "lda_registrant_id": "40305"
          },
          "Business": {
            "annual_profit": null
          },
          "PublicCompany": {
            "ticker": "WMT",
            "sec_cik": 104169
          }
        }
      },
      "links": {
        "self":
        "http://localhost:8080/entities/1-Walmart"
      }
    }
  };

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

  describe('#getEntity', () => {

    it ('resolves a promise of a well-formatted entity on successful response', done => {
      spyOn(window, 'fetch').and.returnValue(responseOf(wmApiJson));
      api.getEntity(1).then((res => {
        expect(res).toEqual(wmApiJson.data.attributes);
        done();
      }));
    });
  });
});
