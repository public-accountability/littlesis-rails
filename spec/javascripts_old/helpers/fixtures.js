fxt = {};

fxt.reference = {
  name: 'Pynchon Wiki',
  url:  'http://pynchonwiki.com'
};

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

fxt.existingEntities = {
  100: {
    id:          "100",
    name:        "Lew Basnight",
    primary_ext: "Person",
    blurb:       "Adjacent to the invisible"
  },
  101: {
    id:          "101",
    name:        "Chums Of Chance",
    primary_ext: "Org",
    blurb:       "Do not -- strictly speaking -- exist"
  }
};

fxt.newAndExistingEntities = {
  newEntity0: {
    id:          "newEntity0",
    name:        "Lew Basnight",
    primary_ext: "Person",
    blurb:       "Adjacent to the invisible"
  },
  101: {
    id:          "101",
    name:        "Chums Of Chance",
    primary_ext: "Org",
    blurb:       "Do not -- strictly speaking -- exist"
  }
};

fxt.entityColumns = [{
  label: 'Name',
  attr:  'name',
  input: 'text'
},{
  label: 'Entity Type',
  attr:  'primary_ext',
  input: 'select'
},{
  label: 'Description',
  attr:  'blurb',
  input: 'text'
}];

fxt.entityCsvValid =
  "name,primary_ext,blurb\n" +
  `${fxt.newEntities.newEntity0.name},${fxt.newEntities.newEntity0.primary_ext},${fxt.newEntities.newEntity0.blurb}\n` +
  `${fxt.newEntities.newEntity1.name},${fxt.newEntities.newEntity1.primary_ext},${fxt.newEntities.newEntity1.blurb}\n`;

fxt.entityCsvValidAltType = 
  "name,primary_ext,blurb\n" +
  "TestOrg1, org ,test org 1 blurb\n" +
  "TestOrg2,O,test org 2 blurb\n" +
  "Test Person One,person,test person 1 blurb\n" +
  "Test Person Two,P,test person 2 blurb\n";

fxt.entityCsvValidOnlyMatches =
  "name,primary_ext,blurb\n" +
  `${fxt.newEntities.newEntity0.name},${fxt.newEntities.newEntity0.primary_ext},${fxt.newEntities.newEntity0.blurb}\n`;

fxt.entityCsvValidNoMatches =
  "name,primary_ext,blurb\n" +
  `${fxt.newEntities.newEntity1.name},${fxt.newEntities.newEntity1.primary_ext},${fxt.newEntities.newEntity1.blurb}\n`;

fxt.entityCsvSample =
  'name,primary_ext,blurb\n'+
  'SampleOrg,Org,Description of SampleOrg\n' +
  'Sample Person,Person,Description of Sample Person';

fxt.entitySearchResultsFor = entity => [0,1,2].map(n => {
  const ext = ["Org", "Person"][n % 2];
  return {
    id:          `${n}${entity.id.slice(-1)}`,
    name:        `${entity.name} dupe name ${n}`,
    blurb:       `dupe description ${n}`,
    primary_ext:  ext,
    url:         `/${ext.toLowerCase()}/${n}/${entity.name.replace(" ", "")}`
  };
});

fxt.entitySearchFake = query => {
  // default implementation of search stub
  // returns match for first new entity, none for second new entity
  switch(query){
  case fxt.newEntities.newEntity0.name:
    return Promise.resolve(fxt.entitySearchResultsFor(fxt.newEntities.newEntity0));
  default:
    return Promise.resolve([]);
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



