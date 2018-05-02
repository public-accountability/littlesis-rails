describe('API module', () => {

  // TODO: (ag|24-Oct-2017) extract this to a support file somewhere?
  const responseOf = (status, payload) => Promise.resolve(
    new Response(JSON.stringify(payload)),
    { status: status }
  );

  const headers = () => ({
    'Accept':       'application/json, text/plain, */*',
    'Content-Type': 'application/json',
    'Littlesis-Request-Type': 'API',
    'X-CSRF-Token': ''
  });

  describe('#searchEntity', () => {

    it('resolves to an array of entities on successful search', done => {
      spyOn(window, 'fetch').and.returnValue(responseOf(200, fxt.walmartSearchResults));
      api.searchEntity('walmart').then((res => {
        expect(res).toEqual(fxt.walmartSearchResultsParsed);
        done();
      }));
    });

    it('resovles to an empty array on failed search', done => {
      spyOn(window, 'fetch')
        .and.returnValue(responseOf(400, { errors: [ { title: "Intentional error for tests." }] }));
      api.searchEntity('walmart').then(res => {
        expect(res).toEqual([]);
        done();
      });
    });
  });

  describe('#createEntities', () => {

    let fetchSpy, response;
    const entities = Object.values(fxt.newEntities);

    describe('successful request', () => {

      beforeAll(done => {
        fetchSpy = spyOn(window, 'fetch').and.returnValue(responseOf(201, fxt.createdEntitiesApiJson));
        api.createEntities(entities).then(res => {
          response = res;
          done();
        });
      });

      it ('formats request according to contract', () => {
        expect(fetchSpy).toHaveBeenCalledWith(
          '/entities/bulk', {
            headers: headers(),
            method: 'post',
            credentials: 'include',
            body: JSON.stringify({
              data: [
                { type: 'entities', attributes: entities[0] },
                { type: 'entities', attributes: entities[1] },
              ]
            })
          }); 
      });

      it('parses array of entities from response', () => {
        expect(response).toEqual(fxt.createdEntitiesParsed);
      });
    });

    describe('failed request', () => {
      
      beforeAll(() => {
        fetchSpy = spyOn(window, 'fetch').and.returnValue(
          responseOf(400, { errors: [ { title: 'OH SHIT!' } ] } )
        );
      });

      it('extracts error message into rejected promise', done => {
        api.createEntities(entities).catch(err => {
          expect(err).toEqual("OH SHIT!");
          done();
        });
      });
    });
  });

  describe('#addEntitiesToList', () => {

    let fetchSpy, response;
    const entities = fxt.createdEntities;
    const reference = {
      name: 'Pynchon Wiki',
      url:  'https://pynchonwiki.com'
    };

    describe('successful request', () => {
      
      beforeAll(done => {
        fetchSpy = spyOn(window, 'fetch')
          .and.returnValue(responseOf(200, fxt.listEntitiesApiJson));
        api.addEntitiesToList(100, [1,2], reference)
          .then(res => {
            response = res;
            done();
          });
      });

      it('formats request according to contract', () => {
        expect(fetchSpy).toHaveBeenCalledWith(
          '/lists/100/entities/bulk', {
            headers: headers(),
            method: 'post',
            credentials: 'include',
            body: JSON.stringify({
              data: [
                { type: 'entities', id: 1 },
                { type: 'entities', id: 2 },
                { type: 'references', attributes: reference }
              ]
            })
          });
      });

      it('parses array of list entities from response', () => {
        expect(response).toEqual(fxt.listEntitiesParsed);
      });
    });

    describe('failed request', () => {
      
      beforeAll(() => {
        fetchSpy = spyOn(window, 'fetch').and.returnValue(
          responseOf(400, { errors: [ { title: 'OH SHIT!' } ] } )
        );
      });

      it('extracts error message into rejected promise', done => {
        api.addEntitiesToList(100, [1,2]).catch(err => {
          expect(err).toEqual("OH SHIT!");
          done();
        });
      });
    });
  });

  describe('#addBlurbToEntity', () => {
    let fetchSpy, response;

    beforeAll(done => {
      let responsePromise = Promise.resolve(new Response(null, { "status": 302 }));
      fetchSpy = spyOn(window, 'fetch').and.returnValue(responsePromise);
      api.addBlurbToEntity('new blurb', 123).then(res => {
        response = res;
        done();
      });
    });


    it('submits request',()  => {
      expect(fetchSpy).toHaveBeenCalledWith(
        '/entities/123', {
          headers: headers(),
          method: 'PATCH',
          credentials: 'include',
          body: JSON.stringify({
	    "entity": { "blurb": 'new blurb' },
	    "reference": { "just_cleaning_up": 1 }
          })
        });
    });
  });
});
