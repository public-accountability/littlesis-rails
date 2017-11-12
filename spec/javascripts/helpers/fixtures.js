fxt = {};

fxt.newEntities = {
  newEntity0: {
    id:          "newEntity0",
    name:        "Lew Basnight",
    primary_ext: "Person",
    blurb:       "Adjacent to the invisible"
  },
  newEntity1: {
    id:          "newEntity1",
    name:        "Chums Of Chance",
    primary_ext: "Org",
    blurb:       "Do not -- strictly speaking -- exist"
  }
};

fxt.createdEntitiesApiJson = {
  "meta": {
    "copyright": "LittleSis CC BY-SA 3.0",
    "license": "https://creativecommons.org/licenses/by-sa/3.0/us/",
    "apiVersion": "2.0-beta"
  },
  "data": [
    {
      "type": "entities",
      "id": 1,
      "attributes": {
        "id": 1,
        "name": "Lew Basnight",
        "blurb": "Adjacent to the invisible",
        "summary": null,
        "website": null,
        "parent_id": null,
        "primary_ext": "Person",
        "updated_at": "2017-11-11T21:33:47Z",
        "start_date": null,
        "end_date": null,
        "aliases": ["Lew Basnight"],
        "types": ["Person"],
        "extensions": {
          "Person": {
            "name_last": "Basnight",
            "name_first": "Lew",
            "name_middle": null,
            "name_prefix": null,
            "name_suffix": null,
            "name_nick": null,
            "birthplace": null,
            "gender_id": null,
            "party_id": null,
            "is_independent": null,
            "net_worth": null,
            "name_maiden": null
          }
        }
      },
      "links": {
        "self": "http://localhost:8080/entities/268593-Lew_Basnight"
      }
    },
    {
      "type": "entities",
      "id": 2,
      "attributes": {
        "id": 2,
        "name": "Chums Of Chance",
        "blurb": "Do not -- strictly speaking -- exist",
        "summary": null,
        "website": null,
        "parent_id": null,
        "primary_ext": "Org",
        "updated_at": "2017-11-11T21:33:47Z",
        "start_date": null,
        "end_date": null,
        "aliases": ["Chums Of Chance"],
        "types": ["Organization"],
        "extensions": {
          "Org": {
            "name": "Chums Of Chance",
            "name_nick": null,
            "employees": null,
            "revenue": null,
            "fedspending_id": null,
            "lda_registrant_id": null
          }
        }
      },
      "links": {
        "self": "http://localhost:8080/entities/268594-Chums_Of_Chance"
      }
    }
  ]
};

fxt.createdEntitiesParsed = [
  {
    "id": "1",
    "name": "Lew Basnight",
    "blurb": "Adjacent to the invisible",
    "summary": null,
    "website": null,
    "parent_id": null,
    "primary_ext": "Person",
    "updated_at": "2017-11-11T21:33:47Z",
    "start_date": null,
    "end_date": null,
    "aliases": ["Lew Basnight"],
    "types": ["Person"],
    "extensions": {
      "Person": {
        "name_last": "Basnight",
        "name_first": "Lew",
        "name_middle": null,
        "name_prefix": null,
        "name_suffix": null,
        "name_nick": null,
        "birthplace": null,
        "gender_id": null,
        "party_id": null,
        "is_independent": null,
        "net_worth": null,
        "name_maiden": null
      }
    }
  },
  {
    "id": "2",
    "name": "Chums Of Chance",
    "blurb": "Do not -- strictly speaking -- exist",
    "summary": null,
    "website": null,
    "parent_id": null,
    "primary_ext": "Org",
    "updated_at": "2017-11-11T21:33:47Z",
    "start_date": null,
    "end_date": null,
    "aliases": ["Chums Of Chance"],
    "types": ["Organization"],
    "extensions": {
      "Org": {
        "name": "Chums Of Chance",
        "name_nick": null,
        "employees": null,
        "revenue": null,
        "fedspending_id": null,
        "lda_registrant_id": null
      }
    }
  },
];

fxt.listEntitiesApiJson = {
  "meta": {
    "copyright": "LittleSis CC BY-SA 3.0",
    "license": "https://creativecommons.org/licenses/by-sa/3.0/us/",
    "apiVersion": "2.0-beta"
  },
  "data": [
    {
      "type": "list-entities",
      "id": 666,
      "attributes": {
        "id": 666,
        "list_id": 100,
        "entity_id": 1,
        "rank": null,
        "updated_at": "2017-11-12T02:25:20Z",
        "custom_field": null
      }
    },
    {
      "type": "list-entities",
      "id": 667,
      "attributes": {
        "id": 667,
        "list_id": 100,
        "entity_id": 2,
        "rank": null,
        "updated_at": "2017-11-12T02:25:20Z",
        "custom_field": null
      }
    }
  ],
  "included": [
    {
      "type": "references",
      "id": 777,
      "attributes":
      {
        "id": 777,
        "document_id": 888,
        "referenceable_id": 999,
        "referenceable_type": "List",
        "updated_at": "2017-11-12T02:27:37Z"
      }
    }
  ]
};

fxt.listEntitiesParsed = [
  {
    "id": "666",
    "list_id": "100",
    "entity_id": "1",
    "rank": null,
    "updated_at": "2017-11-12T02:25:20Z",
    "custom_field": null
  },
  {
    "id": "667",
    "list_id": "100",
    "entity_id": "2",
    "rank": null,
    "updated_at": "2017-11-12T02:25:20Z",
    "custom_field": null

  }
];

// retrieved as logged in user from running dev server on 23-Oct-2017
fxt.walmartSearchResults = [
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

fxt.walmartSearchResultsParsed = [
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

fxt.walmartApiJson = {
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



