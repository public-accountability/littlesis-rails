import { Controller } from "@hotwired/stimulus"

const SPANISH_TRANSLATION = {
  board_members: "Miembros directivos",
  board_memberships: "Juntas directivas a las que pertenece",
  governments: "Gobiernos",
  businesses: "Negocio",
  campaign_contributions: "Contribuciones a campañas electorales federales",
  campaign_contributors: "Donantes de campaña",
  children: "Organizaciones para la infancia",
  donations: "Donaciones",
  donors: "Donantes",
  family: "Familia",
  generic: "Otras conexiones",
  holdings: "Holdings",
  lobbied_by: "Apoyado por",
  lobbies: "Apoya a",
  members: "Miembros",
  memberships: "Membresías",
  offices: "En la oficina de",
  owners: "Propietarios",
  parents: "Padre",
  positions: "Posiciones",
  schools: "Colegios",
  social: "Relación social",
  staff: "Liderazgo y empleados",
  students: "Estudiantes",
  transactions: "Servicios y transacciones"
}


const FRENCH_TRANSLATION = {
  board_members: "Administrateurs",
  board_memberships: "Mandats d'administrateurs",
  governments: "Mandats public",
  businesses: "Fonctions",
  campaign_contributions: "Contributions aux campagnes électorales",
  campaign_contributors: "Contributeur de campagnes électorales",
  children: "Organisations affiliées",
  donations: "Donations",
  donors: "Donateurs",
  family: "Famille",
  generic: "Autres liens",
  holdings: "Société",
  lobbied_by: "Influencé par",
  lobbies: "Influence",
  members: "Membres",
  memberships: "Affiliations",
  offices: "Dans le bureau de",
  owners: "Propriétaires",
  parents: "Parenté",
  positions: "Fonctions",
  schools: "Enseignement",
  social: "Relations sociales",
  staff: "Dirigeants et employés",
  students: "Etudiants",
  transactions: "Services ou Transactions"
}




// English is rendered by default. Unlike most other phrases on our site
// translation done in javascript because profile pages are cached.
export default class extends Controller {
  static values = {
    subcategory: String
  }

  connect() {
    if (this.spanishRequested()) {
      if (SPANISH_TRANSLATION[this.subcategoryValue]) {
        this.element.innerText = SPANISH_TRANSLATION[this.subcategoryValue]
      }
    }
    if (this.frenchRequested()) {
      if (FRENCH_TRANSLATION[this.subcategoryValue]) {
        this.element.innerText = FRENCH_TRANSLATION[this.subcategoryValue]
      }
    }
  }

  spanishRequested() {
    return document.head.querySelector('meta[name="locale"]')?.content === 'es'
  }
  frenchRequested() {
    return document.head.querySelector('meta[name="locale"]')?.content === 'fr'
  }

}
