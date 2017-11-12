describe('API module', () => {

  // TODO: (ag|24-Oct-2017) extract this to a support file somewhere?
  const responseOf = (obj) => Promise.resolve(
    new Response(JSON.stringify(obj)),
    { status: 200 }
  );

  const jsonHeaders = {
    'Accept': 'application/json, text/plain, */*',
    'Content-Type': 'application/json'
  };

  describe('#searchEntity', () => {

    it('resolves to an array of entities on successful search', done => {
      spyOn(window, 'fetch').and.returnValue(responseOf(fxt.walmartSearchResults));
      api.searchEntity('walmart').then((res => {
        expect(res).toEqual(fxt.walmartSearchResultsParsed);
        done();
      }));
    });

    it('resovles to an empty array on failed search', done => {
      spyOn(window, 'fetch').and.returnValue(Promise.reject("Intentional error for tests."));
      api.searchEntity('walmart').then(res => {
        expect(res).toEqual([]);
        done();
      });
    });
  });

  describe('#createEntities', () => {

    let fetchSpy, response;
    const entities = Object.values(fxt.newEntities);

    beforeAll(done => {
      fetchSpy = spyOn(window, 'fetch').and.returnValue(responseOf(fxt.createdEntitiesApiJson));
      api.createEntities(entities).then(res => { response = res; done(); });
    });

    it ('formats request according to contract', () => {
      expect(fetchSpy).toHaveBeenCalledWith(
        '/entities/bulk', {
          headers: jsonHeaders,
          method: 'post',
          credentials: 'include',
          body: {
            data: [
              { type: 'entities', attributes: entities[0] },
              { type: 'entities', attributes: entities[1] },
            ]
          }
        }); 
    });

    it('parses array of entities from response', () => {
      expect(response).toEqual(fxt.createdEntitiesParsed);
    });
  });

  describe('#addEntitiesToList', () => {

    let fetchSpy, response;
    const entities = fxt.createdEntities;

    beforeAll(done => {
      fetchSpy = spyOn(window, 'fetch')
        .and.returnValue(responseOf(fxt.listEntitiesApiJson));
      api.addEntitiesToList(100, [1,2])
        .then(res => {
          response = res;
          done();
        });
    });

    it('formats request according to contract', () => {
      expect(fetchSpy).toHaveBeenCalledWith(
        '/lists/100/associations/entities', {
          headers: jsonHeaders,
          method: 'post',
          credentials: 'include',
          body: {
            data: [
              { type: 'entities', id: 1 },
              { type: 'entities', id: 2 },
            ]
          }
        });
    });

    it('parses array of list entities from response', () => {
      expect(response).toEqual(fxt.listEntitiesParsed);
    });
  });
});
