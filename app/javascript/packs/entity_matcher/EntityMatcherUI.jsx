import React from 'react';

const EntityTitle = () => (
  <div>
    <h2>Entity matcher</h2>
    <hr />
  </div>
);

const EntityInfoDisplay = ({title, value}) => (
  <div>
    <strong>{title}</strong>:  <span>{value}</span>
  </div>
);


const EntityInfo = ({displayData}) => (
  <div>
    { displayData .map( (x, i) => <EntityInfoDisplay key={i} title={x.title} value={x.value} />) }
  </div>
);

export class EntityMatcherUI extends React.Component {
  constructor (props) {
    super(props);
    this.state = { displayData: null };
    this.entityMatcher = 
    this.displayData = [ { title: "one", value: "1"}, { title: "two", value: "2"} ];
  }

  render() {
    return(
      <div>
        <EntityTitle />
        <EntityInfo displayData={this.displayData} />
      </div>
    );
  }
}
