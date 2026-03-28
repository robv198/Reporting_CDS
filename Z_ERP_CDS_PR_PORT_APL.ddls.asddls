@AbapCatalog.viewEnhancementCategory: [#NONE]

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Cube: Requisitions per User'

@Analytics.dataCategory: #CUBE

@Metadata.allowExtensions: true

define view entity Z_ERP_CDS_PR_PORT_APL

  as select from    I_BusinessUserBasic       as User

    left outer join usr21                     as _UserAddress on  User.UserID = _UserAddress.bname

    left outer join I_AddressEmailAddress     as _UserEmail   on  _UserAddress.addrnumber = _UserEmail.AddressID

    left outer join I_AddressPhoneNumber      as _UserPhone   on  _UserAddress.addrnumber = _UserPhone.AddressID

    left outer join I_PurchaseRequisitionItem as _PRItem      on  User.UserID             = _PRItem.CreatedByUser
                                                              and _PRItem.StorageLocation = '3000'
                                                              and _PRItem.IsDeleted       = ''

    left outer join I_PurchaseOrderItemAPI01  as _POItem      on  _PRItem.PurchaseRequisition     = _POItem.PurchaseRequisition
                                                              and _PRItem.PurchaseRequisitionItem = _POItem.PurchaseRequisitionItem

{
  // ─── User ─────────────────────────────────────────────────────────────────

      @UI: {
        lineItem:      [ { position: 10, importance: #HIGH,
                           type: #WITH_INTENT_BASED_NAVIGATION,
                           semanticObjectAction: 'display' } ],
        selectionField: [ { position: 10 } ]
      }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_BusinessUserVH', element: 'UserID' },
                                            useForValidation: true } ]
      @Consumption.semanticObject: 'BusinessUser'
  key User.UserID,

      @UI: {
        lineItem:      [ { position: 20, importance: #HIGH } ],
        selectionField: [ { position: 20 } ]
      }
      User.PersonFullName,

  // ─── Email / Phone ────────────────────────────────────────────────────────

      @Semantics.eMail.address: true
      @Semantics.eMail.type:    [ #WORK ]
      @UI.lineItem: [ { position: 30, importance: #MEDIUM } ]
      _UserEmail.EmailAddress                                        as Email,

      @Semantics.telephone.number: true
      @Semantics.telephone.type:   [ #WORK ]
      @UI.lineItem: [ { position: 40, importance: #MEDIUM } ]
      _UserPhone.PhoneNumber                                         as PhoneNumber,

  // ─── Purchase Requisition ─────────────────────────────────────────────────

      @UI: {
        lineItem:      [ { position: 50, importance: #HIGH,
                           type: #WITH_INTENT_BASED_NAVIGATION,
                           semanticObjectAction: 'display' } ],
        selectionField: [ { position: 30 } ]
      }
      // I_PurchaseRequisitionVH is the dedicated value help entity for PR numbers
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PurchaseRequisitionVH', element: 'PurchaseRequisition' },
                                            useForValidation: true } ]
      @Consumption.semanticObject: 'PurchaseRequisition'
  key _PRItem.PurchaseRequisition,

      @UI.lineItem: [ { position: 60, importance: #HIGH } ]
  key _PRItem.PurchaseRequisitionItem,

      // Date picker is rendered automatically for DATS fields;
      // @Semantics.systemDate.createdAt marks this as the creation timestamp.
      @Semantics.systemDate.createdAt: true
      @UI: {
        lineItem:      [ { position: 70, importance: #MEDIUM } ],
        selectionField: [ { position: 40 } ]
      }
      _PRItem.CreationDate,

  // ─── Material ─────────────────────────────────────────────────────────────

      @UI.lineItem: [ { position: 80, importance: #MEDIUM,
                        type: #WITH_INTENT_BASED_NAVIGATION,
                        semanticObjectAction: 'display' } ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProductStdVH', element: 'Product' },
                                            useForValidation: true } ]
      @Consumption.semanticObject: 'Material'
      _PRItem.Material,

      @UI.lineItem: [ { position: 90, importance: #LOW } ]
      _PRItem.PurchaseRequisitionItemText,

  // ─── Logistics ────────────────────────────────────────────────────────────

      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_StorageLocationStdVH', element: 'StorageLocation' },
                                            useForValidation: true } ]
      _PRItem.StorageLocation,

      @UI: {
        lineItem:      [ { position: 100, importance: #MEDIUM } ],
        selectionField: [ { position: 50 } ]
      }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Plant', element: 'Plant' },
                                            useForValidation: true } ]
      _PRItem.Plant,

  // ─── Quantities ───────────────────────────────────────────────────────────

      @Semantics.quantity.unitOfMeasure: 'ReqUnit'
      @Aggregation.default: #SUM
      @UI.lineItem: [ { position: 110, importance: #MEDIUM } ]
      cast( _PRItem.RequestedQuantity as abap.int4 )                 as RequestedQuantity,

      @Aggregation.default: #SUM
      @UI.lineItem: [ { position: 120, importance: #LOW } ]
      case when _PRItem.PurchaseRequisition is not initial
           then 1
           else 0
      end                                                            as ItemCounter,

      _PRItem.BaseUnit                                               as ReqUnit,

  // ─── Status ───────────────────────────────────────────────────────────────

      @UI.lineItem: [ { position: 130, importance: #MEDIUM } ]
      _PRItem.PurchaseRequisitionStatus,

      @UI: {
        lineItem:      [ { position: 140, importance: #HIGH,
                           type: #WITH_INTENT_BASED_NAVIGATION,
                           semanticObjectAction: 'display' } ],
        selectionField: [ { position: 60 } ]
      }
      // I_PurchaseOrderVH is the dedicated value help entity for PO numbers
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PurchaseOrderVH', element: 'PurchaseOrder' },
                                            useForValidation: true } ]
      @Consumption.semanticObject: 'PurchaseOrder'
      _POItem.PurchaseOrder,

      @UI.lineItem: [ { position: 150, importance: #LOW } ]
      _POItem.IsCompletelyDelivered,

      @UI.lineItem: [ { position: 160, importance: #LOW } ]
      _POItem.IsFinallyInvoiced,

  // ─── Filter-only fields (hidden from list) ────────────────────────────────

      upper( ltrim(User.UserID, ' ') )                               as UserIDFilter,

      cast( upper( ltrim(User.PersonFullName, ' ') ) as zuser_name ) as PersonFullNameFilter

}
