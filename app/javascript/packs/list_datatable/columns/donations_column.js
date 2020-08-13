const currencyFormatter = Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  currencyDisplay: 'symbol'
});

export const DonationsColumn = {
  data: 'total_usd_donations',
  name: 'total USD donations',
  width: "30%",
  visible: true,
  render: function(data, type, row) {
    return currencyFormatter.format(row.total_usd_donations).replace('.00', '');
  }
}
