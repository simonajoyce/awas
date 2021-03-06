CREATE OR REPLACE PACKAGE por_CUSTOM_pkg AUTHID CURRENT_USER as
/* $Header: PORCUSTS.pls 120.2.12010000.3 2014/06/16 07:18:37 fenyan ship $ */


-- Customize this procedure to add custom defaulting logic for all the
-- attributes on a requisition header.
-- This is called when a new requisition gets created.
-- The attribute id's are passed as IN OUT NOCOPY parameters to this procedure and
-- can be modified to reflect any custom defaulting logic.


PROCEDURE CUSTOM_DEFAULT_REQ_HEADER (
    req_header_id            IN NUMBER,	-- 1
    old_req_header_id        IN NUMBER,   -- 2
    req_num                  IN VARCHAR2, -- 3
    preparer_id              IN NUMBER, -- 4
    x_req_type                 IN OUT NOCOPY  VARCHAR2, -- 5
    x_emergency_po_num         IN OUT NOCOPY  VARCHAR2, -- 6
    x_approval_status_code     IN OUT NOCOPY  VARCHAR2, -- 7
    x_cancel_flag              IN OUT NOCOPY  VARCHAR2, -- 8
    x_closed_code              IN OUT NOCOPY  VARCHAR2, -- 9
    x_org_id                   IN OUT NOCOPY  NUMBER, -- 10
    x_wf_item_type             IN OUT NOCOPY  VARCHAR2, -- 11
    x_wf_item_key              IN OUT NOCOPY  VARCHAR2, -- 12
    x_pcard_id                 IN OUT NOCOPY  NUMBER, -- 13
    x_attribute1               IN OUT NOCOPY  VARCHAR2, -- 14
    x_attribute2               IN OUT NOCOPY  VARCHAR2, -- 15
    x_attribute3               IN OUT NOCOPY  VARCHAR2, -- 16
    x_attribute4               IN OUT NOCOPY  VARCHAR2, -- 17
    x_attribute5               IN OUT NOCOPY  VARCHAR2, -- 18
    x_attribute6               IN OUT NOCOPY  VARCHAR2, -- 19
    x_attribute7               IN OUT NOCOPY  VARCHAR2, -- 20
    x_attribute8               IN OUT NOCOPY  VARCHAR2, -- 21
    x_attribute9               IN OUT NOCOPY  VARCHAR2, -- 22
    x_attribute10              IN OUT NOCOPY  VARCHAR2, -- 23
    x_attribute11              IN OUT NOCOPY  VARCHAR2, -- 24
    x_attribute12              IN OUT NOCOPY  VARCHAR2, -- 25
    x_attribute13              IN OUT NOCOPY  VARCHAR2, -- 26
    x_attribute14              IN OUT NOCOPY  VARCHAR2, -- 27
    x_attribute15              IN OUT NOCOPY  VARCHAR2, -- 28
    x_return_code                OUT NOCOPY NUMBER, -- 29
    x_error_msg                  OUT NOCOPY VARCHAR2 -- 30
  );


-- Customize this procedure to add logic for validation of the attribute values
-- on a requisition header. This  would be any custom validation, that would
-- be in addition to all the validations done for a requisition header.
-- The return_msg and the error_code can be used to return the results of
-- the validation
-- The return code can be used to indicate on which tab the error message
-- needs to be displayed on the Edit Lines page
-- If the result code is 1, error is displayed on the Delivery tab
-- If the result code is 2, error is displayed on the Billing tab
-- If the result code is 3, error is displayed on the Accounts tab

PROCEDURE CUSTOM_VALIDATE_REQ_HEADER (
    req_header_id            IN  NUMBER, -- 1
    req_num                  IN  VARCHAR2, -- 2
    preparer_id	       IN  NUMBER,	-- 3
    req_type                 IN  VARCHAR2, -- 4
    emergency_po_num         IN  VARCHAR2, -- 5
    approval_status_code     IN  VARCHAR2, -- 6
    cancel_flag              IN  VARCHAR2, -- 7
    closed_code              IN  VARCHAR2, -- 8
    org_id                   IN  NUMBER, -- 9
    wf_item_type             IN  VARCHAR2, -- 10
    wf_item_key              IN  VARCHAR2, -- 11
    pcard_id                 IN  NUMBER, -- 12
    attribute1               IN  VARCHAR2, -- 13
    attribute2               IN  VARCHAR2, -- 14
    attribute3               IN  VARCHAR2, -- 15
    attribute4               IN  VARCHAR2, -- 16
    attribute5               IN  VARCHAR2, -- 17
    attribute6               IN  VARCHAR2, -- 18
    attribute7               IN  VARCHAR2, -- 19
    attribute8               IN  VARCHAR2, -- 20
    attribute9               IN  VARCHAR2, -- 21
    attribute10              IN  VARCHAR2, -- 22
    attribute11              IN  VARCHAR2, -- 23
    attribute12              IN  VARCHAR2, -- 24
    attribute13              IN  VARCHAR2, -- 25
    attribute14              IN  VARCHAR2, -- 26
    attribute15              IN  VARCHAR2, -- 27
    x_return_code                OUT NOCOPY NUMBER, -- 28
    x_error_msg                  OUT NOCOPY VARCHAR2 -- 29
  );


-- Customize this procedure to add custom defaulting logic for all the
-- attributes on a requisition line.
-- This is called when a new line gets added to the requisition.
-- The attribute id's are passed as IN OUT NOCOPY parameters to this procedure and
-- can be modified to reflect any custom defaulting logic.
-- The values corresponding to the id's are recalculated in the calling ReqLine
-- Java class


PROCEDURE CUSTOM_DEFAULT_REQ_LINE (
-- READ ONLY data
    req_header_id            IN NUMBER,	-- 1
    req_line_id              IN NUMBER,	-- 2
    old_req_line_id          IN NUMBER,   -- 3
    line_num                 IN NUMBER,	-- 4

-- header data
    preparer_id                IN NUMBER, -- 5
    header_attribute_1         IN VARCHAR2, -- 6
    header_attribute_2         IN VARCHAR2, -- 7
    header_attribute_3         IN VARCHAR2, -- 8
    header_attribute_4         IN VARCHAR2, -- 9
    header_attribute_5         IN VARCHAR2, -- 10
    header_attribute_6         IN VARCHAR2, -- 11
    header_attribute_7         IN VARCHAR2, -- 12
    header_attribute_8         IN VARCHAR2, -- 13
    header_attribute_9         IN VARCHAR2, -- 14
    header_attribute_10        IN VARCHAR2, -- 15
    header_attribute_11        IN VARCHAR2, -- 16
    header_attribute_12        IN VARCHAR2, -- 17
    header_attribute_13        IN VARCHAR2, -- 18
    header_attribute_14        IN VARCHAR2, -- 19
    header_attribute_15        IN VARCHAR2, -- 20

-- line data: update any of the following parameters as default for line
    x_line_type_id             IN OUT NOCOPY  NUMBER, -- 21
    x_item_id                  IN OUT NOCOPY  NUMBER, -- 22
    x_item_revision            IN OUT NOCOPY  VARCHAR2, -- 23
    x_category_id              IN OUT NOCOPY  NUMBER, -- 24
    x_catalog_source           IN OUT NOCOPY  VARCHAR2, -- 25
    x_catalog_type             IN OUT NOCOPY  VARCHAR2, -- 26
    x_currency_code            IN OUT NOCOPY  VARCHAR2, -- 27
    x_currency_unit_price      IN OUT NOCOPY  NUMBER, -- 28
    x_manufacturer_name        IN OUT NOCOPY  VARCHAR2, -- 29
    x_manufacturer_part_num    IN OUT NOCOPY  VARCHAR2, -- 30
    x_deliver_to_loc_id        IN OUT NOCOPY  NUMBER, -- 31
    x_deliver_to_org_id        IN OUT NOCOPY  NUMBER, -- 32
    x_deliver_to_subinv        IN OUT NOCOPY  VARCHAR2, -- 33
    x_destination_type_code    IN OUT NOCOPY  VARCHAR2, -- 34
    x_requester_id             IN OUT NOCOPY  NUMBER, -- 35
    x_encumbered_flag          IN OUT NOCOPY  VARCHAR2, -- 36
    x_hazard_class_id          IN OUT NOCOPY  NUMBER, -- 37
    x_modified_by_buyer        IN OUT NOCOPY  VARCHAR2, -- 38
    x_need_by_date             IN OUT NOCOPY  DATE, -- 39
    x_new_supplier_flag        IN OUT NOCOPY  VARCHAR2, -- 40
    x_on_rfq_flag              IN OUT NOCOPY  VARCHAR2, -- 41
    x_org_id                   IN OUT NOCOPY  NUMBER, -- 42
    x_parent_req_line_id       IN OUT NOCOPY  NUMBER, -- 43
    x_po_line_loc_id           IN OUT NOCOPY  NUMBER, -- 44
    x_qty_cancelled            IN OUT NOCOPY  NUMBER, -- 45
    x_qty_delivered            IN OUT NOCOPY  NUMBER, -- 46
    x_qty_ordered              IN OUT NOCOPY  NUMBER, -- 47
    x_qty_received             IN OUT NOCOPY  NUMBER, -- 48
    x_rate                     IN OUT NOCOPY  NUMBER, -- 49
    x_rate_date                IN OUT NOCOPY  DATE, -- 50
    x_rate_type                IN OUT NOCOPY  VARCHAR2, -- 51
    x_rfq_required             IN OUT NOCOPY  VARCHAR2, -- 52
    x_source_type_code         IN OUT NOCOPY  VARCHAR2, -- 53
    x_spsc_code                IN OUT NOCOPY  VARCHAR2, -- 54
    x_other_category_code      IN OUT NOCOPY  VARCHAR2, -- 55
    x_suggested_buyer_id       IN OUT NOCOPY  NUMBER, -- 56
    x_source_doc_header_id     IN OUT NOCOPY  NUMBER, -- 57
    x_source_doc_line_num      IN OUT NOCOPY  NUMBER, -- 58
    x_source_doc_type_code     IN OUT NOCOPY  VARCHAR2, -- 59
    x_supplier_duns            IN OUT NOCOPY  VARCHAR2, -- 60
    x_supplier_item_num        IN OUT NOCOPY  VARCHAR2, -- 61
    x_taxable_status           IN OUT NOCOPY  VARCHAR2, -- 62
    x_unit_of_measure          IN OUT NOCOPY  VARCHAR2, -- 63
    x_unit_price               IN OUT NOCOPY  NUMBER, -- 64
    x_urgent                   IN OUT NOCOPY  VARCHAR2, -- 65
    x_supplier_contact_id      IN OUT NOCOPY  NUMBER, -- 66
    x_supplier_id              IN OUT NOCOPY  NUMBER, -- 67
    x_supplier_site_id         IN OUT NOCOPY  NUMBER, -- 68
    x_cancel_date              IN OUT NOCOPY  DATE, -- 69
    x_cancel_flag              IN OUT NOCOPY  VARCHAR2, -- 70
    x_closed_code              IN OUT NOCOPY  VARCHAR2, -- 71
    x_closed_date              IN OUT NOCOPY  DATE, -- 72
    x_auto_receive_flag        IN OUT NOCOPY  VARCHAR2, -- 73
    x_pcard_flag               IN OUT NOCOPY  VARCHAR2, -- 74
    x_attribute1               IN OUT NOCOPY  VARCHAR2, -- 75
    x_attribute2               IN OUT NOCOPY  VARCHAR2, -- 76
    x_attribute3               IN OUT NOCOPY  VARCHAR2, -- 77
    x_attribute4               IN OUT NOCOPY  VARCHAR2, -- 78
    x_attribute5               IN OUT NOCOPY  VARCHAR2, -- 79
    x_attribute6               IN OUT NOCOPY  VARCHAR2, -- 80
    x_attribute7               IN OUT NOCOPY  VARCHAR2, -- 81
    x_attribute8               IN OUT NOCOPY  VARCHAR2, -- 82
    x_attribute9               IN OUT NOCOPY  VARCHAR2, -- 83
    x_attribute10              IN OUT NOCOPY  VARCHAR2, -- 84
    x_attribute11              IN OUT NOCOPY  VARCHAR2, -- 85
    x_attribute12              IN OUT NOCOPY  VARCHAR2, -- 86
    x_attribute13              IN OUT NOCOPY  VARCHAR2, -- 87
    x_attribute14              IN OUT NOCOPY  VARCHAR2, -- 88
    x_attribute15              IN OUT NOCOPY  VARCHAR2, -- 89
    X_return_code                OUT NOCOPY NUMBER, -- 90
    X_error_msg                  OUT NOCOPY VARCHAR2, -- 91
    x_supplierContact          IN OUT NOCOPY  VARCHAR2, -- 92
    x_supplierContactPhone     IN OUT NOCOPY  VARCHAR2, -- 93
    x_supplier		       IN OUT NOCOPY  VARCHAR2, -- 94
    x_supplierSite	       IN OUT NOCOPY  VARCHAR2, -- 95
    x_taxCodeId	       IN OUT NOCOPY  NUMBER, -- 96
    x_source_org_id    IN OUT NOCOPY NUMBER, -- 97
    x_txn_reason_code    IN OUT NOCOPY VARCHAR2, -- 98
    x_note_to_agent		IN OUT NOCOPY VARCHAR2, --99
    x_note_to_receiver		IN OUT NOCOPY VARCHAR2, --100
    x_note_to_vendor		IN OUT NOCOPY VARCHAR2 --101
  );


-- Customize this procedure to add logic for validation of the attribute values
-- on a requisition line. This would be any custom validation, that would be
-- in addition to all the validations done for a requisition line
-- This is called whenever the requisition line gets updated and is called
-- on every page in the checkOUT NOCOPY flow.
-- The return_msg and the error_code can be used to return the results of
-- the validation
-- The return code can be used to indicate on which tab the error message
-- needs to be displayed on the Edit Lines page
-- If the result code is 1, error is displayed on the Delivery tab
-- If the result code is 2, error is displayed on the Billing tab
-- If the result code is 3, error is displayed on the Accounts tab



PROCEDURE CUSTOM_VALIDATE_REQ_LINE (
    x_req_header_id            IN  NUMBER, -- 1
    x_req_line_id              IN  NUMBER, -- 2
    x_line_num                 IN  NUMBER, -- 3


-- header data
    preparer_id                IN NUMBER, -- 4
    header_attribute_1         IN VARCHAR2, -- 5
    header_attribute_2         IN VARCHAR2, -- 6
    header_attribute_3         IN VARCHAR2, -- 7
    header_attribute_4         IN VARCHAR2, -- 8
    header_attribute_5         IN VARCHAR2, -- 9
    header_attribute_6         IN VARCHAR2, -- 10
    header_attribute_7         IN VARCHAR2, -- 11
    header_attribute_8         IN VARCHAR2, -- 12
    header_attribute_9         IN VARCHAR2, -- 13
    header_attribute_10        IN VARCHAR2, -- 14
    header_attribute_11        IN VARCHAR2, -- 15
    header_attribute_12        IN VARCHAR2, -- 16
    header_attribute_13        IN VARCHAR2, -- 17
    header_attribute_14        IN VARCHAR2, -- 18
    header_attribute_15        IN VARCHAR2, -- 19

-- line data
    line_type_id             IN  NUMBER, -- 20
    item_id                  IN  NUMBER, -- 21
    item_revision            IN  VARCHAR2, -- 22
    category_id              IN  NUMBER, -- 23
    catalog_source           IN  VARCHAR2, -- 24
    catalog_type             IN  VARCHAR2, -- 25
    currency_code            IN  VARCHAR2, -- 26
    currency_unit_price      IN  NUMBER, -- 27
    manufacturer_name        IN  VARCHAR2, --28
    manufacturer_part_num    IN  VARCHAR2, -- 29
    deliver_to_loc_id        IN  NUMBER, -- 30
    deliver_to_org_id        IN  NUMBER, -- 31
    deliver_to_subinv        IN  VARCHAR2, -- 32
    destination_type_code    IN  VARCHAR2, -- 33
    requester_id             IN  NUMBER, -- 34
    encumbered_flag          IN  VARCHAR2, -- 35
    hazard_class_id          IN  NUMBER, -- 36
    modified_by_buyer        IN  VARCHAR2, -- 37
    need_by_date             IN  DATE, -- 38
    new_supplier_flag        IN  VARCHAR2, -- 39
    on_rfq_flag              IN  VARCHAR2, -- 40
    org_id                   IN  NUMBER, -- 41
    parent_req_line_id       IN  NUMBER, -- 42
    po_line_loc_id           IN  NUMBER, -- 43
    qty_cancelled            IN  NUMBER, -- 44
    qty_delivered            IN  NUMBER, -- 45
    qty_ordered              IN  NUMBER, -- 46
    qty_received             IN  NUMBER, -- 47
    rate                     IN  NUMBER, -- 48
    rate_date                IN  DATE, -- 49
    rate_type                IN  VARCHAR2, -- 50
    rfq_required             IN  VARCHAR2, -- 51
    source_type_code         IN  VARCHAR2, -- 52
    spsc_code                IN  VARCHAR2, -- 53
    other_category_code      IN  VARCHAR2, -- 54
    suggested_buyer_id       IN OUT NOCOPY NUMBER, -- 55
    source_doc_header_id     IN  NUMBER, -- 56
    source_doc_line_num      IN  NUMBER, -- 57
    source_doc_type_code     IN  VARCHAR2, -- 58
    supplier_duns            IN  VARCHAR2, -- 59
    supplier_item_num        IN  VARCHAR2, -- 60
    taxable_status           IN  VARCHAR2, -- 61
    unit_of_measure          IN  VARCHAR2, -- 62
    unit_price               IN  NUMBER, -- 63
    urgent                   IN  VARCHAR2, -- 64
    supplier_contact_id      IN  NUMBER, -- 65
    supplier_id              IN  NUMBER, -- 66
    supplier_site_id         IN  NUMBER, -- 67
    cancel_date              IN  DATE, -- 68
    cancel_flag              IN  VARCHAR2, -- 69
    closed_code              IN  VARCHAR2, -- 70
    closed_date              IN  DATE, -- 71
    auto_receive_flag        IN  VARCHAR2, -- 72
    pcard_flag               IN  VARCHAR2, -- 73
    attribute1               IN  VARCHAR2, -- 74
    attribute2               IN  VARCHAR2, -- 75
    attribute3               IN  VARCHAR2, -- 76
    attribute4               IN  VARCHAR2, -- 77
    attribute5               IN  VARCHAR2, -- 78
    attribute6               IN  VARCHAR2, -- 79
    attribute7               IN  VARCHAR2, -- 80
    attribute8               IN  VARCHAR2, -- 81
    attribute9               IN  VARCHAR2, -- 82
    attribute10              IN  VARCHAR2, -- 83
    attribute11              IN  VARCHAR2, -- 84
    attribute12              IN  VARCHAR2, -- 85
    attribute13              IN  VARCHAR2, -- 86
    attribute14              IN  VARCHAR2, -- 87
    attribute15              IN  VARCHAR2, -- 88
    x_taxCodeId	           IN NUMBER,    -- 89
    x_return_code            OUT NOCOPY NUMBER, -- 90 no error
    x_error_msg              OUT NOCOPY VARCHAR2, -- 91
    x_source_org_id	     IN NUMBER, -- 92
    x_txn_reason_code	     IN VARCHAR2 -- 93
  );




-- Customize this procedure to add custom defaulting logic for all the
-- attributes on a requisition distribution.
-- This is called when a new distribution gets added to the requisition.
-- The attribute id's are passed as IN OUT NOCOPY parameters to this procedure and
-- can be modified to reflect any custom defaulting logic.


PROCEDURE CUSTOM_DEFAULT_REQ_DIST (

    x_distribution_id       IN NUMBER,  -- 1
    x_old_distribution_id   IN NUMBER,  -- 2
    x_code_combination_id   IN OUT NOCOPY   NUMBER, -- 3
    x_budget_account_id   IN OUT NOCOPY   NUMBER, -- 4
    x_variance_account_id   IN OUT NOCOPY   NUMBER, -- 5
    x_accrual_account_id   IN OUT NOCOPY   NUMBER, -- 6
    project_id		      IN OUT NOCOPY NUMBER, -- 7
    task_id		      IN OUT NOCOPY NUMBER, -- 8
    expenditure_type	      IN OUT NOCOPY VARCHAR2, -- 9
    expenditure_organization_id IN OUT NOCOPY NUMBER, -- 10
    expenditure_item_date    IN OUT NOCOPY DATE, -- 11
    award_id                 IN OUT NOCOPY NUMBER, -- 12
    gl_encumbered_date	     IN OUT NOCOPY DATE,	-- 13
    gl_period_name           IN OUT NOCOPY VARCHAR2, -- 14
    gl_cancelled_date        IN OUT NOCOPY DATE, -- 15
    gl_closed_date           IN OUT NOCOPY DATE,--16
    gl_date                  IN OUT NOCOPY DATE,--17
    gl_encumbered_period     IN OUT NOCOPY VARCHAR2,--18
    recovery_rate            IN OUT NOCOPY NUMBER, -- 19
    tax_recovery_override_flag IN OUT NOCOPY VARCHAR2, -- 20
    chart_of_accounts_id     IN  NUMBER, -- 21
    category_id 	     IN  NUMBER, -- 22
    catalog_source           IN  VARCHAR2, -- 23
    catalog_type             IN  VARCHAR2, -- 24
    destination_type_code    IN  VARCHAR2, -- 25
    deliver_to_location_id   IN  NUMBER, -- 26
    destination_organization_id IN NUMBER, -- 27
    destination_subinventory IN  VARCHAR2, -- 28
    item_id			IN  NUMBER, -- 29
    sob_id                      IN NUMBER, -- 30
    currency_code               IN VARCHAR2, -- 31
    currency_unit_price         IN NUMBER, -- 32
    manufacturer_name           IN VARCHAR2, -- 33
    manufacturer_part_num       IN VARCHAR2,-- 34
    need_by_date                IN DATE, -- 35
    new_supplier_flag           IN VARCHAR2, -- 36
    business_org_id             IN NUMBER,    -- 37
    org_id                      IN NUMBER, -- 38
    employee_id                 IN NUMBER, -- 39
    employee_org_id       IN      NUMBER,  -- 40
    default_code_combination_id IN NUMBER, -- 41
    parent_req_line_id       IN  NUMBER, -- 42
    qty_cancelled            IN  NUMBER, -- 43
    qty_delivered            IN  NUMBER, -- 44
    qty_ordered              IN  NUMBER, -- 45
    qty_received             IN  NUMBER, -- 46
    rate                     IN  NUMBER, -- 47
    rate_date                IN  DATE, -- 48
    rate_type                IN  VARCHAR2, -- 49
    source_type_code         IN  VARCHAR2, -- 50
    spsc_code                IN  VARCHAR2, -- 51
    suggested_buyer_id       IN  NUMBER, -- 52
    source_doc_header_id     IN  NUMBER, -- 53
    source_doc_line_num      IN  NUMBER, -- 54
    source_doc_type_code     IN  VARCHAR2, -- 55
    supplier_item_num        IN  VARCHAR2, -- 56
    taxable_status           IN  VARCHAR2, -- 57
    unit_of_measure          IN  VARCHAR2, -- 58
    unit_price               IN  NUMBER, -- 59
    supplier_contact_id      IN  NUMBER, -- 60
    supplier_id              IN  NUMBER, -- 61
    supplier_site_id         IN  NUMBER, -- 62
    pcard_flag               IN  VARCHAR2, -- 63
    line_type_id	     IN  NUMBER, -- 64
    taxCodeId	             IN   NUMBER, -- 65
    results_billable_flag    IN VARCHAR2,-- 66
    preparer_id	   	     IN  NUMBER, -- 67
    deliver_to_person_id	IN  NUMBER, -- 68
    po_encumberance_flag	IN  VARCHAR2, -- 69
    DATE_FORMAT		IN  VARCHAR2,	-- 70
    header_att1		  IN  VARCHAR2,	-- 71
    header_att2		  IN  VARCHAR2,	-- 72
    header_att3		  IN  VARCHAR2,	-- 73
    header_att4		  IN  VARCHAR2,	-- 74
    header_att5		  IN  VARCHAR2,	-- 75
    header_att6		  IN  VARCHAR2,	-- 76
    header_att7		  IN  VARCHAR2,	-- 77
    header_att8		  IN  VARCHAR2,	-- 78
    header_att9		  IN  VARCHAR2,	-- 79
    header_att10	  IN  VARCHAR2,	-- 80
    header_att11	  IN  VARCHAR2,	-- 81
    header_att12	  IN  VARCHAR2,	-- 82
    header_att13          IN  VARCHAR2,	-- 83
    header_att14	  IN  VARCHAR2,	-- 84
    header_att15	  IN  VARCHAR2,	-- 85
    line_att1		  IN  VARCHAR2,	-- 86
    line_att2		  IN  VARCHAR2,	-- 87
    line_att3		  IN  VARCHAR2,	-- 88
    line_att4		  IN  VARCHAR2,	-- 89
    line_att5		  IN  VARCHAR2,	-- 90
    line_att6		  IN  VARCHAR2,	-- 91
    line_att7		  IN  VARCHAR2,	-- 92
    line_att8		  IN  VARCHAR2,	-- 93
    line_att9		  IN  VARCHAR2,	-- 94
    line_att10		  IN  VARCHAR2,	-- 95
    line_att11		  IN  VARCHAR2,	-- 96
    line_att12		  IN  VARCHAR2,	-- 97
    line_att13		  IN  VARCHAR2,	-- 98
    line_att14		  IN  VARCHAR2,	-- 99
    line_att15		  IN  VARCHAR2,	-- 100
    distribution_att1	  IN OUT NOCOPY  VARCHAR2, -- 101
    distribution_att2	  IN OUT NOCOPY  VARCHAR2, -- 102
    distribution_att3	  IN OUT NOCOPY  VARCHAR2, -- 103
    distribution_att4	  IN OUT NOCOPY  VARCHAR2, -- 104
    distribution_att5	  IN OUT NOCOPY  VARCHAR2, -- 105
    distribution_att6	  IN OUT NOCOPY  VARCHAR2, -- 106
    distribution_att7	  IN OUT NOCOPY  VARCHAR2, -- 107
    distribution_att8	  IN OUT NOCOPY  VARCHAR2, -- 108
    distribution_att9	  IN OUT NOCOPY  VARCHAR2, -- 109
    distribution_att10	  IN OUT NOCOPY  VARCHAR2, -- 110
    distribution_att11	  IN OUT NOCOPY  VARCHAR2, -- 111
    distribution_att12	  IN OUT NOCOPY  VARCHAR2, -- 112
    distribution_att13	  IN OUT NOCOPY  VARCHAR2, -- 113
    distribution_att14	  IN OUT NOCOPY  VARCHAR2, -- 114
    distribution_att15	  IN OUT NOCOPY  VARCHAR2, -- 115
    result_code           OUT NOCOPY     NUMBER,  -- 116
    x_error_msg           OUT NOCOPY     VARCHAR2 -- 117
);

-- Customize this procedure to add logic for validation of the attribute values
-- on a requisition distribution. This would be any custom validation, that
-- would be in addition to all the validations done for a requisition
-- distribution.
-- The return_msg and the error_code can be used to return the results of
-- the validation
-- The return code can be used to indicate on which tab the error message
-- needs to be displayed on the Edit Lines page
-- If the result code is 1, error is displayed on the Delivery tab
-- If the result code is 2, error is displayed on the Billing tab
-- If the result code is 3, error is displayed on the Accounts tab


PROCEDURE CUSTOM_VALIDATE_REQ_DIST (

    x_distribution_id IN NUMBER, -- 1
    x_code_combination_id   IN   NUMBER, -- 2
    x_budget_account_id   IN    NUMBER, -- 3
    x_variance_account_id   IN   NUMBER, -- 4
    x_accrual_account_id   IN    NUMBER, -- 5
    project_id		      IN NUMBER, -- 6
    task_id		      IN NUMBER, -- 7
    expenditure_type	      IN VARCHAR2, -- 8
    expenditure_organization_id IN NUMBER, -- 9
    expenditure_item_date    IN DATE, -- 10
    award_id                 IN NUMBER, -- 11
    gl_encumbered_date	     IN DATE,	-- 12
    gl_period_name           IN VARCHAR2, -- 13
    gl_cancelled_date        IN DATE, -- 14
    gl_closed_date           IN DATE,--15
    gl_date                  IN DATE,--16
    gl_encumbered_period     IN VARCHAR2,--17
    recovery_rate            IN NUMBER, -- 18
    tax_recovery_override_flag IN VARCHAR2, -- 19
    chart_of_accounts_id     IN  NUMBER, -- 20
    category_id 	     IN  NUMBER, -- 21
    catalog_source           IN  VARCHAR2, -- 22
    catalog_type             IN  VARCHAR2, -- 23
    destination_type_code    IN  VARCHAR2, -- 24
    deliver_to_location_id   IN  NUMBER, -- 25
    destination_organization_id IN NUMBER, -- 26
    destination_subinventory IN  VARCHAR2, -- 27
    item_id			IN  NUMBER, -- 28
    sob_id                      IN NUMBER, -- 29
    currency_code               IN VARCHAR2, -- 30
    currency_unit_price         IN NUMBER, -- 31
    manufacturer_name           IN VARCHAR2, -- 32
    manufacturer_part_num       IN VARCHAR2,-- 33
    need_by_date                IN DATE, -- 34
    new_supplier_flag           IN VARCHAR2, -- 35
    business_org_id             IN NUMBER,    -- 36
    org_id                      IN NUMBER, -- 37
    employee_id                 IN NUMBER, -- 38
    employee_org_id       IN      NUMBER,  -- 39
    default_code_combination_id IN NUMBER, -- 40
    parent_req_line_id       IN  NUMBER, -- 41
    qty_cancelled            IN  NUMBER, -- 42
    qty_delivered            IN  NUMBER, -- 43
    qty_ordered              IN  NUMBER, -- 44
    qty_received             IN  NUMBER, -- 45
    rate                     IN  NUMBER, -- 46
    rate_date                IN  DATE, -- 47
    rate_type                IN  VARCHAR2, -- 48
    source_type_code         IN  VARCHAR2, -- 49
    spsc_code                IN  VARCHAR2, -- 50
    suggested_buyer_id       IN  NUMBER, -- 51
    source_doc_header_id     IN  NUMBER, -- 52
    source_doc_line_num      IN  NUMBER, -- 53
    source_doc_type_code     IN  VARCHAR2, -- 54
    supplier_item_num        IN  VARCHAR2, -- 55
    taxable_status           IN  VARCHAR2, -- 56
    unit_of_measure          IN  VARCHAR2, -- 57
    unit_price               IN  NUMBER, -- 58
    supplier_contact_id      IN  NUMBER, -- 59
    supplier_id              IN  NUMBER, -- 60
    supplier_site_id         IN  NUMBER, -- 61
    pcard_flag               IN  VARCHAR2, -- 62
    line_type_id	     IN  NUMBER, -- 63
    taxCodeId	             IN   NUMBER, -- 64
    results_billable_flag    IN VARCHAR2,-- 65
    preparer_id	   	     IN  NUMBER, -- 66
    deliver_to_person_id	IN  NUMBER, -- 67
    po_encumberance_flag	IN  VARCHAR2, -- 68
    DATE_FORMAT		IN  VARCHAR2,	-- 69
    header_att1		  IN  VARCHAR2,	-- 70
    header_att2		  IN  VARCHAR2,	-- 71
    header_att3		  IN  VARCHAR2,	-- 72
    header_att4		  IN  VARCHAR2,	-- 73
    header_att5		  IN  VARCHAR2,	-- 74
    header_att6		  IN  VARCHAR2,	-- 75
    header_att7		  IN  VARCHAR2,	-- 76
    header_att8		  IN  VARCHAR2,	-- 77
    header_att9		  IN  VARCHAR2,	-- 78
    header_att10	  IN  VARCHAR2,	-- 79
    header_att11	  IN  VARCHAR2,	-- 80
    header_att12	  IN  VARCHAR2,	-- 81
    header_att13          IN  VARCHAR2,	-- 82
    header_att14	  IN  VARCHAR2,	-- 83
    header_att15	  IN  VARCHAR2,	-- 84
    line_att1		  IN  VARCHAR2,	-- 85
    line_att2		  IN  VARCHAR2,	-- 86
    line_att3		  IN  VARCHAR2,	-- 87
    line_att4		  IN  VARCHAR2,	-- 88
    line_att5		  IN  VARCHAR2,	-- 89
    line_att6		  IN  VARCHAR2,	-- 90
    line_att7		  IN  VARCHAR2,	-- 91
    line_att8		  IN  VARCHAR2,	-- 92
    line_att9		  IN  VARCHAR2,	-- 93
    line_att10		  IN  VARCHAR2,	-- 94
    line_att11		  IN  VARCHAR2,	-- 95
    line_att12		  IN  VARCHAR2,	-- 96
    line_att13		  IN  VARCHAR2,	-- 97
    line_att14		  IN  VARCHAR2,	-- 98
    line_att15		  IN  VARCHAR2,	-- 99
    distribution_att1	  IN   VARCHAR2, -- 100
    distribution_att2	  IN   VARCHAR2, -- 101
    distribution_att3	  IN   VARCHAR2, -- 102
    distribution_att4	  IN   VARCHAR2, -- 103
    distribution_att5	  IN   VARCHAR2, -- 104
    distribution_att6	  IN   VARCHAR2, -- 105
    distribution_att7	  IN   VARCHAR2, -- 106
    distribution_att8	  IN   VARCHAR2, -- 107
    distribution_att9	  IN   VARCHAR2, -- 108
    distribution_att10	  IN   VARCHAR2, -- 109
    distribution_att11	  IN   VARCHAR2, -- 110
    distribution_att12	  IN   VARCHAR2, -- 111
    distribution_att13	  IN   VARCHAR2, -- 112
    distribution_att14	  IN   VARCHAR2, -- 113
    distribution_att15	  IN   VARCHAR2, -- 114
    result_code           OUT NOCOPY     NUMBER,  -- 115
    x_error_msg           OUT NOCOPY     VARCHAR2 -- 116
);


-- Customize this procedure to handle updates to charge accounts.
-- The caller passes the charge account segments values in p_seg_vals,
-- and the new segments values should be returned in the same parameter.
-- Null is passed for the value of the read-only and hidden segments.
-- p_changed_seg is the index of the segment that the user changed this time.
-- p_orig_ccid is the CCID in the distribution before any user changes.
-- Any changes made by the user before a submit event are not reflected in
-- p_orig_ccid.

PROCEDURE CUSTOM_UPDATE_CHARGE_ACCOUNT(
  p_orig_ccid   IN     NUMBER, -- the code-combination ID before any user changes
  p_changed_seg IN     NUMBER, -- index of the changed segment (starts at 0)
  p_seg_vals    IN OUT NOCOPY POR_CHARGE_ACCT_SEG_TBL_TYPE, -- table of segment values
  result_code      OUT NOCOPY NUMBER,
  x_error_msg      OUT NOCOPY VARCHAR2
);

-- Since we will be obsoleting existing wf for RCO Req Approval tolerance
-- check, this procedure is provided to implement a hook for existing
-- customizations.
--
--  Parameters :
--    p_chreqgrp_id : change request group id
--    x_appr_status : approval status
--    x_skip_std_logic : determines whether standard tolerance check
--                       product logic will be skipped after calling
--                       this procedure or not.
PROCEDURE CUSTOM_RCO_REQAPPR_TOL_CHECK (
  p_chreqgrp_id IN NUMBER,
  x_appr_status OUT NOCOPY VARCHAR2,
  x_skip_std_logic OUT NOCOPY VARCHAR2 );

END por_CUSTOM_pkg;

/


CREATE OR REPLACE PACKAGE BODY por_custom_pkg AS
/* $Header: PORCUSTB.pls 120.2.12010000.3 2014/06/16 07:19:20 fenyan ship $ */


-- Customize this procedure to add custom defaulting logic for all the
-- attributes on a requisition header.
-- This is called when a new requisition gets created.
-- The attribute id's are passed as IN OUT NOCOPY parameters to this procedure and
-- can be modified to reflect any custom defaulting logic.

PROCEDURE CUSTOM_DEFAULT_REQ_HEADER (
    req_header_id            IN NUMBER,	-- 1
    old_req_header_id        IN NUMBER,   -- 2
    req_num                  IN VARCHAR2, -- 3
    preparer_id              IN NUMBER, -- 4
    x_req_type                 IN OUT NOCOPY  VARCHAR2, -- 5
    x_emergency_po_num         IN OUT NOCOPY  VARCHAR2, -- 6
    x_approval_status_code     IN OUT NOCOPY  VARCHAR2, -- 7
    x_cancel_flag              IN OUT NOCOPY  VARCHAR2, -- 8
    x_closed_code              IN OUT NOCOPY  VARCHAR2, -- 9
    x_org_id                   IN OUT NOCOPY  NUMBER, -- 10
    x_wf_item_type             IN OUT NOCOPY  VARCHAR2, -- 11
    x_wf_item_key              IN OUT NOCOPY  VARCHAR2, -- 12
    x_pcard_id                 IN OUT NOCOPY  NUMBER, -- 13
    x_attribute1               IN OUT NOCOPY  VARCHAR2, -- 14
    x_attribute2               IN OUT NOCOPY  VARCHAR2, -- 15
    x_attribute3               IN OUT NOCOPY  VARCHAR2, -- 16
    x_attribute4               IN OUT NOCOPY  VARCHAR2, -- 17
    x_attribute5               IN OUT NOCOPY  VARCHAR2, -- 18
    x_attribute6               IN OUT NOCOPY  VARCHAR2, -- 19
    x_attribute7               IN OUT NOCOPY  VARCHAR2, -- 20
    x_attribute8               IN OUT NOCOPY  VARCHAR2, -- 21
    x_attribute9               IN OUT NOCOPY  VARCHAR2, -- 22
    x_attribute10              IN OUT NOCOPY  VARCHAR2, -- 23
    x_attribute11              IN OUT NOCOPY  VARCHAR2, -- 24
    x_attribute12              IN OUT NOCOPY  VARCHAR2, -- 25
    x_attribute13              IN OUT NOCOPY  VARCHAR2, -- 26
    x_attribute14              IN OUT NOCOPY  VARCHAR2, -- 27
    x_attribute15              IN OUT NOCOPY  VARCHAR2, -- 28
    x_return_code                OUT NOCOPY NUMBER, -- 29
    x_error_msg                  OUT NOCOPY VARCHAR2 -- 30
  )
  is
BEGIN
-- AWAS Custom to set Attibute1 = Users default cost centre
  SELECT gcc.segment3
  INTO x_attribute1
  FROM gl_code_combinations gcc, per_all_assignments_f paa
  WHERE PAA.DEFAULT_CODE_COMB_ID = GCC.CODE_COMBINATION_ID
  and sysdate between paa.effective_start_date and paa.effective_end_date
  and paa.assignment_status_type_id = 1
  AND paa.person_id = (SELECT employee_id FROM
  fnd_user where user_id = fnd_profile.value('USER_ID'));

  --if fnd_profile.value('USER_ID') = 1642
  --then x_emergency_po_num := 'Y';
  --end if;



   X_RETURN_CODE:=0;
   X_ERROR_MSG:='';
END CUSTOM_DEFAULT_REQ_HEADER;


-- Customize this procedure to add logic for validation of the attribute values
-- on a requisition header. This  would be any custom validation, that would
-- be in addition to all the validations done for a requisition header.
-- The return_msg and the error_code can be used to return the results of
-- the validation
-- The return code can be used to indicate on which tab the error message
-- needs to be displayed on the Edit Lines page
-- If the result code is 1, error is displayed on the Delivery tab
-- If the result code is 2, error is displayed on the Billing tab
-- If the result code is 3, error is displayed on the Accounts tab

PROCEDURE CUSTOM_VALIDATE_REQ_HEADER (
    req_header_id            IN  NUMBER, -- 1
    req_num                  IN  VARCHAR2, -- 2
    preparer_id	       IN  NUMBER,	-- 3
    req_type                 IN  VARCHAR2, -- 4
    emergency_po_num         IN  VARCHAR2, -- 5
    approval_status_code     IN  VARCHAR2, -- 6
    cancel_flag              IN  VARCHAR2, -- 7
    closed_code              IN  VARCHAR2, -- 8
    org_id                   IN  NUMBER, -- 9
    wf_item_type             IN  VARCHAR2, -- 10
    wf_item_key              IN  VARCHAR2, -- 11
    pcard_id                 IN  NUMBER, -- 12
    attribute1               IN  VARCHAR2, -- 13
    attribute2               IN  VARCHAR2, -- 14
    attribute3               IN  VARCHAR2, -- 15
    attribute4               IN  VARCHAR2, -- 16
    attribute5               IN  VARCHAR2, -- 17
    attribute6               IN  VARCHAR2, -- 18
    attribute7               IN  VARCHAR2, -- 19
    attribute8               IN  VARCHAR2, -- 20
    attribute9               IN  VARCHAR2, -- 21
    attribute10              IN  VARCHAR2, -- 22
    attribute11              IN  VARCHAR2, -- 23
    attribute12              IN  VARCHAR2, -- 24
    attribute13              IN  VARCHAR2, -- 25
    attribute14              IN  VARCHAR2, -- 26
    attribute15              IN  VARCHAR2, -- 27
    x_return_code                OUT NOCOPY NUMBER, -- 28
    x_error_msg                  OUT NOCOPY VARCHAR2 -- 29
  )
  IS
 xx_project_id      NUMBER;
  xx_req_desc        varchar2(240);
  l_resp_id          number;
  l_req_amount     number;
  l_doc_count number;
BEGIN



-- AWAS Requisition Description Customisation
-- If Project number entered then set Requistion Description to Project Number plus ERquisition Description enter in flex
 fnd_profile.get('RESP_ID',l_resp_id);


  if l_resp_id = 50962 then  -- TAM Responsibility

  --set default to OK
   x_return_code:=0;
   x_error_msg:='';

            if attribute12 is null then
            x_return_code:=1;
            x_error_msg:='You must enter a default Expenditure Type. Press Cancel below to navigate back to first page';
            end if;

            if attribute13 is null then
            x_return_code:=1;
            x_error_msg:='You must enter a requisition description. Press Cancel below to navigate back to first page';
            end if;

            if attribute10 is null then
             x_return_code:=1;
             x_error_msg:='You must select a Project/MSN. Press Cancel below to navigate back to first page';
            end if;

  elsif l_resp_id = 51823 then  -- Training requests
   x_return_code:=0;
   x_error_msg:='';
  
       select sum(unit_price*quantity)
       into l_req_amount
       from po_requisition_lines_all
       where requisition_header_id = req_header_id;
       
       if l_req_amount < 1 then
       
       
                     x_return_code:=1;
                     x_error_msg:= x_error_msg||' Please Enter the cost of the Training. Press Cancel below to navigate back to first page';
       end if;
  
        if l_req_amount >= 5000 then   -- total order over 5k
              
              SELECT count(*)
              into l_doc_count
                  FROM fnd_attached_documents fad
                  WHERE  FAD.CATEGORY_ID = 1000765
                  and entity_name = 'REQ_HEADERS' 
                  AND pk1_value in req_header_id;
                  
                  if l_doc_count = 0 then 
                     x_return_code:=1;
                     x_error_msg:=x_error_msg||' As this course is over $5000 you must upload a Training Assistance Form and use the Training Assistance Form category. Press Cancel below to navigate back to first page';
                 end if;
        end if;
        
              SELECT count(*)
              into l_doc_count
                  FROM fnd_attached_documents fad
                  WHERE  FAD.CATEGORY_ID in (1, 1000766) --Miscellaneous or Training Details
                  and entity_name = 'REQ_HEADERS' 
                  AND pk1_value in req_header_id;
                  
                  if l_doc_count = 0 then 
                     x_return_code:=1;
                     x_error_msg:=x_error_msg||' Please upload a supporting attachment to this request. Press Cancel below to navigate back to first page';
                 end if;
        
  
  else
   x_return_code:=0;
   x_error_msg:='';
  end if;
  
 
END CUSTOM_VALIDATE_REQ_HEADER;


-- Customize this procedure to add custom defaulting logic for all the
-- attributes on a requisition line.
-- This is called when a new line gets added to the requisition.
-- The attribute id's are passed as IN OUT NOCOPY parameters to this procedure and
-- can be modified to reflect any custom defaulting logic.
-- The values corresponding to the id's are recalculated in the calling ReqLine
-- Java class

PROCEDURE CUSTOM_DEFAULT_REQ_LINE (
-- READ ONLY data
    req_header_id            IN NUMBER,	-- 1
    req_line_id              IN NUMBER,	-- 2
    old_req_line_id          IN NUMBER,   -- 3
    line_num                 IN NUMBER,	-- 4

-- header data
    preparer_id                IN NUMBER, -- 5
    header_attribute_1         IN VARCHAR2, -- 6
    header_attribute_2         IN VARCHAR2, -- 7
    header_attribute_3         IN VARCHAR2, -- 8
    header_attribute_4         IN VARCHAR2, -- 9
    header_attribute_5         IN VARCHAR2, -- 10
    header_attribute_6         IN VARCHAR2, -- 11
    header_attribute_7         IN VARCHAR2, -- 12
    header_attribute_8         IN VARCHAR2, -- 13
    header_attribute_9         IN VARCHAR2, -- 14
    header_attribute_10        IN VARCHAR2, -- 15
    header_attribute_11        IN VARCHAR2, -- 16
    header_attribute_12        IN VARCHAR2, -- 17
    header_attribute_13        IN VARCHAR2, -- 18
    header_attribute_14        IN VARCHAR2, -- 19
    header_attribute_15        IN VARCHAR2, -- 20

-- line data: update any of the following parameters as default for line
    x_line_type_id             IN OUT NOCOPY  NUMBER, -- 21
    x_item_id                  IN OUT NOCOPY  NUMBER, -- 22
    x_item_revision            IN OUT NOCOPY  VARCHAR2, -- 23
    x_category_id              IN OUT NOCOPY  NUMBER, -- 24
    x_catalog_source           IN OUT NOCOPY  VARCHAR2, -- 25
    x_catalog_type             IN OUT NOCOPY  VARCHAR2, -- 26
    x_currency_code            IN OUT NOCOPY  VARCHAR2, -- 27
    x_currency_unit_price      IN OUT NOCOPY  NUMBER, -- 28
    x_manufacturer_name        IN OUT NOCOPY  VARCHAR2, -- 29
    x_manufacturer_part_num    IN OUT NOCOPY  VARCHAR2, -- 30
    x_deliver_to_loc_id        IN OUT NOCOPY  NUMBER, -- 31
    x_deliver_to_org_id        IN OUT NOCOPY  NUMBER, -- 32
    x_deliver_to_subinv        IN OUT NOCOPY  VARCHAR2, -- 33
    x_destination_type_code    IN OUT NOCOPY  VARCHAR2, -- 34
    x_requester_id             IN OUT NOCOPY  NUMBER, -- 35
    x_encumbered_flag          IN OUT NOCOPY  VARCHAR2, -- 36
    x_hazard_class_id          IN OUT NOCOPY  NUMBER, -- 37
    x_modified_by_buyer        IN OUT NOCOPY  VARCHAR2, -- 38
    x_need_by_date             IN OUT NOCOPY  DATE, -- 39
    x_new_supplier_flag        IN OUT NOCOPY  VARCHAR2, -- 40
    x_on_rfq_flag              IN OUT NOCOPY  VARCHAR2, -- 41
    x_org_id                   IN OUT NOCOPY  NUMBER, -- 42
    x_parent_req_line_id       IN OUT NOCOPY  NUMBER, -- 43
    x_po_line_loc_id           IN OUT NOCOPY  NUMBER, -- 44
    x_qty_cancelled            IN OUT NOCOPY  NUMBER, -- 45
    x_qty_delivered            IN OUT NOCOPY  NUMBER, -- 46
    x_qty_ordered              IN OUT NOCOPY  NUMBER, -- 47
    x_qty_received             IN OUT NOCOPY  NUMBER, -- 48
    x_rate                     IN OUT NOCOPY  NUMBER, -- 49
    x_rate_date                IN OUT NOCOPY  DATE, -- 50
    x_rate_type                IN OUT NOCOPY  VARCHAR2, -- 51
    x_rfq_required             IN OUT NOCOPY  VARCHAR2, -- 52
    x_source_type_code         IN OUT NOCOPY  VARCHAR2, -- 53
    x_spsc_code                IN OUT NOCOPY  VARCHAR2, -- 54
    x_other_category_code      IN OUT NOCOPY  VARCHAR2, -- 55
    x_suggested_buyer_id       IN OUT NOCOPY  NUMBER, -- 56
    x_source_doc_header_id     IN OUT NOCOPY  NUMBER, -- 57
    x_source_doc_line_num      IN OUT NOCOPY  NUMBER, -- 58
    x_source_doc_type_code     IN OUT NOCOPY  VARCHAR2, -- 59
    x_supplier_duns            IN OUT NOCOPY  VARCHAR2, -- 60
    x_supplier_item_num        IN OUT NOCOPY  VARCHAR2, -- 61
    x_taxable_status           IN OUT NOCOPY  VARCHAR2, -- 62
    x_unit_of_measure          IN OUT NOCOPY  VARCHAR2, -- 63
    x_unit_price               IN OUT NOCOPY  NUMBER, -- 64
    x_urgent                   IN OUT NOCOPY  VARCHAR2, -- 65
    x_supplier_contact_id      IN OUT NOCOPY  NUMBER, -- 66
    x_supplier_id              IN OUT NOCOPY  NUMBER, -- 67
    x_supplier_site_id         IN OUT NOCOPY  NUMBER, -- 68
    x_cancel_date              IN OUT NOCOPY  DATE, -- 69
    x_cancel_flag              IN OUT NOCOPY  VARCHAR2, -- 70
    x_closed_code              IN OUT NOCOPY  VARCHAR2, -- 71
    x_closed_date              IN OUT NOCOPY  DATE, -- 72
    x_auto_receive_flag        IN OUT NOCOPY  VARCHAR2, -- 73
    x_pcard_flag               IN OUT NOCOPY  VARCHAR2, -- 74
    x_attribute1               IN OUT NOCOPY  VARCHAR2, -- 75
    x_attribute2               IN OUT NOCOPY  VARCHAR2, -- 76
    x_attribute3               IN OUT NOCOPY  VARCHAR2, -- 77
    x_attribute4               IN OUT NOCOPY  VARCHAR2, -- 78
    x_attribute5               IN OUT NOCOPY  VARCHAR2, -- 79
    x_attribute6               IN OUT NOCOPY  VARCHAR2, -- 80
    x_attribute7               IN OUT NOCOPY  VARCHAR2, -- 81
    x_attribute8               IN OUT NOCOPY  VARCHAR2, -- 82
    x_attribute9               IN OUT NOCOPY  VARCHAR2, -- 83
    x_attribute10              IN OUT NOCOPY  VARCHAR2, -- 84
    x_attribute11              IN OUT NOCOPY  VARCHAR2, -- 85
    x_attribute12              IN OUT NOCOPY  VARCHAR2, -- 86
    x_attribute13              IN OUT NOCOPY  VARCHAR2, -- 87
    x_attribute14              IN OUT NOCOPY  VARCHAR2, -- 88
    x_attribute15              IN OUT NOCOPY  VARCHAR2, -- 89
    X_return_code                OUT NOCOPY NUMBER, -- 90
    X_error_msg                  OUT NOCOPY VARCHAR2, -- 91
    x_supplierContact          IN OUT NOCOPY  VARCHAR2, -- 92
    x_supplierContactPhone     IN OUT NOCOPY  VARCHAR2, -- 93
    x_supplier		       IN OUT NOCOPY  VARCHAR2, -- 94
    x_supplierSite	       IN OUT NOCOPY  VARCHAR2, -- 95
    x_taxCodeId	       IN OUT NOCOPY  NUMBER, -- 96
    x_source_org_id    IN OUT NOCOPY  NUMBER, -- 97
    x_txn_reason_code    IN OUT NOCOPY  VARCHAR2, -- 98
    x_note_to_agent		IN OUT NOCOPY VARCHAR2, --99
    x_note_to_receiver		IN OUT NOCOPY VARCHAR2, --100
    x_note_to_vendor		IN OUT NOCOPY VARCHAR2 --101

  ) IS
 xx_project_id number;
  l_proj varchar2(1);

BEGIN

-- AWAS Hardcoded buyer to AWAS Buyer if null

   IF x_suggested_buyer_id IS NULL THEN

   SELECT nvl(A.agent_id,2527)
   INTO x_suggested_buyer_id
   from  po_agents A,
         per_all_people_f p
   WHERE p.person_id = preparer_id
   and p.person_id= A.agent_id (+);


   end if;



-- Update buyer to Projects buyer
BEGIN

select decode(noncat_template_id,162,'Y',163,'Y','N')
into l_proj
from po_requisition_lines_all
where requisition_line_id = to_number(req_line_id);

if header_attribute_10 is not null and l_proj = 'Y' then

   xx_project_id := to_number(header_attribute_10);

-- Set suggested_buyer_id
SELECT person_id
into x_suggested_buyer_id
FROM pa_project_players
WHERE project_role_type = '1001'
AND project_id = xx_project_id;

END IF;


exception
WHEN OThers then
x_suggested_buyer_id := 2527;  -- AWAS Default

END;



-- Default Need By to Line Entered Need By Date

   IF x_attribute1 IS NOT NULL THEN

   SELECT to_date(x_attribute1,'YYYY/MM/DD HH24:MI:SS')
   --to_char(to_date(x_attribute1,'YYYY/MM/DD HH24:MI:SS'),'DD/MMM/YYYY')
   INTO x_need_by_date
   FROM dual;

   ELSE
   --IF header_attribute_11 IS NOT NULL AND x_attribute1 IS NULL THEN
   IF x_attribute1 IS NULL THEN

   if header_attribute_11 is not null then
   x_need_by_date := to_date(header_attribute_11,'YYYY/MM/DD HH24:MI:SS');
   END IF;


   end if;


   END IF;



   x_attribute7:= req_line_id;
   X_RETURN_CODE:=0;
   X_ERROR_MSG:='';

exception
WHEN others THEN
x_suggested_buyer_id := 2527;
X_RETURN_CODE:=0;
   X_ERROR_MSG:='';
END;


-- Customize this procedure to add logic for validation of the attribute values
-- on a requisition line. This would be any custom validation, that would be
-- in addition to all the validations done for a requisition line
-- This is called whenever the requisition line gets updated and is called
-- on every page in the checkOUT NOCOPY flow.
-- The return_msg and the error_code can be used to return the results of
-- the validation
-- The return code can be used to indicate on which tab the error message
-- needs to be displayed on the Edit Lines page
-- If the result code is 1, error is displayed on the Delivery tab
-- If the result code is 2, error is displayed on the Billing tab
-- If the result code is 3, error is displayed on the Accounts tab


PROCEDURE CUSTOM_VALIDATE_REQ_LINE (
  x_req_header_id            IN  NUMBER, -- 1
    x_req_line_id              IN  NUMBER, -- 2
    x_line_num                 IN  NUMBER, -- 3


-- header data
    preparer_id                IN NUMBER, -- 4
    header_attribute_1         IN VARCHAR2, -- 5
    header_attribute_2         IN VARCHAR2, -- 6
    header_attribute_3         IN VARCHAR2, -- 7
    header_attribute_4         IN VARCHAR2, -- 8
    header_attribute_5         IN VARCHAR2, -- 9
    header_attribute_6         IN VARCHAR2, -- 10
    header_attribute_7         IN VARCHAR2, -- 11
    header_attribute_8         IN VARCHAR2, -- 12
    header_attribute_9         IN VARCHAR2, -- 13
    header_attribute_10        IN VARCHAR2, -- 14
    header_attribute_11        IN VARCHAR2, -- 15
    header_attribute_12        IN VARCHAR2, -- 16
    header_attribute_13        IN VARCHAR2, -- 17
    header_attribute_14        IN VARCHAR2, -- 18
    header_attribute_15        IN VARCHAR2, -- 19

-- line data
    line_type_id             IN  NUMBER, -- 20
    item_id                  IN  NUMBER, -- 21
    item_revision            IN  VARCHAR2, -- 22
    category_id              IN  NUMBER, -- 23
    catalog_source           IN  VARCHAR2, -- 24
    catalog_type             IN  VARCHAR2, -- 25
    currency_code            IN  VARCHAR2, -- 26
    currency_unit_price      IN  NUMBER, -- 27
    manufacturer_name        IN  VARCHAR2, --28
    manufacturer_part_num    IN  VARCHAR2, -- 29
    deliver_to_loc_id        IN  NUMBER, -- 30
    deliver_to_org_id        IN  NUMBER, -- 31
    deliver_to_subinv        IN  VARCHAR2, -- 32
    destination_type_code    IN  VARCHAR2, -- 33
    requester_id             IN  NUMBER, -- 34
    encumbered_flag          IN  VARCHAR2, -- 35
    hazard_class_id          IN  NUMBER, -- 36
    modified_by_buyer        IN  VARCHAR2, -- 37
    need_by_date             IN  DATE, -- 38
    new_supplier_flag        IN  VARCHAR2, -- 39
    on_rfq_flag              IN  VARCHAR2, -- 40
    org_id                   IN  NUMBER, -- 41
    parent_req_line_id       IN  NUMBER, -- 42
    po_line_loc_id           IN  NUMBER, -- 43
    qty_cancelled            IN  NUMBER, -- 44
    qty_delivered            IN  NUMBER, -- 45
    qty_ordered              IN  NUMBER, -- 46
    qty_received             IN  NUMBER, -- 47
    rate                     IN  NUMBER, -- 48
    rate_date                IN  DATE, -- 49
    rate_type                IN  VARCHAR2, -- 50
    rfq_required             IN  VARCHAR2, -- 51
    source_type_code         IN  VARCHAR2, -- 52
    spsc_code                IN  VARCHAR2, -- 53
    other_category_code      IN  VARCHAR2, -- 54
    suggested_buyer_id       IN OUT NOCOPY NUMBER, -- 55
    source_doc_header_id     IN  NUMBER, -- 56
    source_doc_line_num      IN  NUMBER, -- 57
    source_doc_type_code     IN  VARCHAR2, -- 58
    supplier_duns            IN  VARCHAR2, -- 59
    supplier_item_num        IN  VARCHAR2, -- 60
    taxable_status           IN  VARCHAR2, -- 61
    unit_of_measure          IN  VARCHAR2, -- 62
    unit_price               IN  NUMBER, -- 63
    urgent                   IN  VARCHAR2, -- 64
    supplier_contact_id      IN  NUMBER, -- 65
    supplier_id              IN  NUMBER, -- 66
    supplier_site_id         IN  NUMBER, -- 67
    cancel_date              IN  DATE, -- 68
    cancel_flag              IN  VARCHAR2, -- 69
    closed_code              IN  VARCHAR2, -- 70
    closed_date              IN  DATE, -- 71
    auto_receive_flag        IN  VARCHAR2, -- 72
    pcard_flag               IN  VARCHAR2, -- 73
    attribute1               IN  VARCHAR2, -- 74
    attribute2               IN  VARCHAR2, -- 75
    attribute3               IN  VARCHAR2, -- 76
    attribute4               IN  VARCHAR2, -- 77
    attribute5               IN  VARCHAR2, -- 78
    attribute6               IN  VARCHAR2, -- 79
    attribute7               IN  VARCHAR2, -- 80
    attribute8               IN  VARCHAR2, -- 81
    attribute9               IN  VARCHAR2, -- 82
    attribute10              IN  VARCHAR2, -- 83
    attribute11              IN  VARCHAR2, -- 84
    attribute12              IN  VARCHAR2, -- 85
    attribute13              IN  VARCHAR2, -- 86
    attribute14              IN  VARCHAR2, -- 87
    attribute15              IN  VARCHAR2, -- 88
    x_taxCodeId	           IN NUMBER,    -- 89
    x_return_code            OUT NOCOPY NUMBER, -- 90 no error
    x_error_msg              OUT NOCOPY VARCHAR2, -- 91
    x_source_org_id 	     IN NUMBER, -- 92
    x_txn_reason_code 	     IN VARCHAR2 -- 93

  )
  IS
BEGIN
   X_RETURN_CODE:=0;
   X_ERROR_MSG:='';
END;




-- Customize this procedure to add custom defaulting logic for all the
-- attributes on a requisition distribution.
-- This is called when a new distribution gets added to the requisition.
-- The attribute id's are passed as IN OUT NOCOPY parameters to this procedure and
-- can be modified to reflect any custom defaulting logic.

PROCEDURE CUSTOM_DEFAULT_REQ_DIST (
    x_distribution_id       IN NUMBER,  -- 1
    x_old_distribution_id   IN NUMBER,  -- 2
    x_code_combination_id   IN OUT NOCOPY   NUMBER, -- 3
    x_budget_account_id   IN OUT NOCOPY   NUMBER, -- 4
    x_variance_account_id   IN OUT NOCOPY   NUMBER, -- 5
    x_accrual_account_id   IN OUT NOCOPY   NUMBER, -- 6
    project_id		      IN OUT NOCOPY NUMBER, -- 7
    task_id		      IN OUT NOCOPY NUMBER, -- 8
    expenditure_type	      IN OUT NOCOPY VARCHAR2, -- 9
    expenditure_organization_id IN OUT NOCOPY NUMBER, -- 10
    expenditure_item_date    IN OUT NOCOPY DATE, -- 11
    award_id                 IN OUT NOCOPY NUMBER, -- 12
    gl_encumbered_date	     IN OUT NOCOPY DATE,	-- 13
    gl_period_name           IN OUT NOCOPY VARCHAR2, -- 14
    gl_cancelled_date        IN OUT NOCOPY DATE, -- 15
    gl_closed_date           IN OUT NOCOPY DATE,--16
    gl_date                  IN OUT NOCOPY DATE,--17
    gl_encumbered_period     IN OUT NOCOPY VARCHAR2,--18
    recovery_rate            IN OUT NOCOPY NUMBER, -- 19
    tax_recovery_override_flag IN OUT NOCOPY VARCHAR2, -- 20
    chart_of_accounts_id     IN  NUMBER, -- 21
    category_id 	     IN  NUMBER, -- 22
    catalog_source           IN  VARCHAR2, -- 23
    catalog_type             IN  VARCHAR2, -- 24
    destination_type_code    IN  VARCHAR2, -- 25
    deliver_to_location_id   IN  NUMBER, -- 26
    destination_organization_id IN NUMBER, -- 27
    destination_subinventory IN  VARCHAR2, -- 28
    item_id			IN  NUMBER, -- 29
    sob_id                      IN NUMBER, -- 30
    currency_code               IN VARCHAR2, -- 31
    currency_unit_price         IN NUMBER, -- 32
    manufacturer_name           IN VARCHAR2, -- 33
    manufacturer_part_num       IN VARCHAR2,-- 34
    need_by_date                IN DATE, -- 35
    new_supplier_flag           IN VARCHAR2, -- 36
    business_org_id             IN NUMBER,    -- 37
    org_id                      IN NUMBER, -- 38
    employee_id                 IN NUMBER, -- 39
    employee_org_id       IN      NUMBER,  -- 40
    default_code_combination_id IN NUMBER, -- 41
    parent_req_line_id       IN  NUMBER, -- 42
    qty_cancelled            IN  NUMBER, -- 43
    qty_delivered            IN  NUMBER, -- 44
    qty_ordered              IN  NUMBER, -- 45
    qty_received             IN  NUMBER, -- 46
    rate                     IN  NUMBER, -- 47
    rate_date                IN  DATE, -- 48
    rate_type                IN  VARCHAR2, -- 49
    source_type_code         IN  VARCHAR2, -- 50
    spsc_code                IN  VARCHAR2, -- 51
    suggested_buyer_id       IN  NUMBER, -- 52
    source_doc_header_id     IN  NUMBER, -- 53
    source_doc_line_num      IN  NUMBER, -- 54
    source_doc_type_code     IN  VARCHAR2, -- 55
    supplier_item_num        IN  VARCHAR2, -- 56
    taxable_status           IN  VARCHAR2, -- 57
    unit_of_measure          IN  VARCHAR2, -- 58
    unit_price               IN  NUMBER, -- 59
    supplier_contact_id      IN  NUMBER, -- 60
    supplier_id              IN  NUMBER, -- 61
    supplier_site_id         IN  NUMBER, -- 62
    pcard_flag               IN  VARCHAR2, -- 63
    line_type_id	     IN  NUMBER, -- 64
    taxCodeId	             IN   NUMBER, -- 65
    results_billable_flag    IN VARCHAR2,-- 66
    preparer_id	   	     IN  NUMBER, -- 67
    deliver_to_person_id	IN  NUMBER, -- 68
    po_encumberance_flag	IN  VARCHAR2, -- 69
    DATE_FORMAT		IN  VARCHAR2,	-- 70
    header_att1		  IN  VARCHAR2,	-- 71
    header_att2		  IN  VARCHAR2,	-- 72
    header_att3		  IN  VARCHAR2,	-- 73
    header_att4		  IN  VARCHAR2,	-- 74
    header_att5		  IN  VARCHAR2,	-- 75
    header_att6		  IN  VARCHAR2,	-- 76
    header_att7		  IN  VARCHAR2,	-- 77
    header_att8		  IN  VARCHAR2,	-- 78
    header_att9		  IN  VARCHAR2,	-- 79
    header_att10	  IN  VARCHAR2,	-- 80
    header_att11	  IN  VARCHAR2,	-- 81
    header_att12	  IN  VARCHAR2,	-- 82
    header_att13          IN  VARCHAR2,	-- 83
    header_att14	  IN  VARCHAR2,	-- 84
    header_att15	  IN  VARCHAR2,	-- 85
    line_att1		  IN  VARCHAR2,	-- 86
    line_att2		  IN  VARCHAR2,	-- 87
    line_att3		  IN  VARCHAR2,	-- 88
    line_att4		  IN  VARCHAR2,	-- 89
    line_att5		  IN  VARCHAR2,	-- 90
    line_att6		  IN  VARCHAR2,	-- 91
    line_att7		  IN  VARCHAR2,	-- 92
    line_att8		  IN  VARCHAR2,	-- 93
    line_att9		  IN  VARCHAR2,	-- 94
    line_att10		  IN  VARCHAR2,	-- 95
    line_att11		  IN  VARCHAR2,	-- 96
    line_att12		  IN  VARCHAR2,	-- 97
    line_att13		  IN  VARCHAR2,	-- 98
    line_att14		  IN  VARCHAR2,	-- 99
    line_att15		  IN  VARCHAR2,	-- 100
    distribution_att1	  IN OUT NOCOPY  VARCHAR2, -- 101
    distribution_att2	  IN OUT NOCOPY  VARCHAR2, -- 102
    distribution_att3	  IN OUT NOCOPY  VARCHAR2, -- 103
    distribution_att4	  IN OUT NOCOPY  VARCHAR2, -- 104
    distribution_att5	  IN OUT NOCOPY  VARCHAR2, -- 105
    distribution_att6	  IN OUT NOCOPY  VARCHAR2, -- 106
    distribution_att7	  IN OUT NOCOPY  VARCHAR2, -- 107
    distribution_att8	  IN OUT NOCOPY  VARCHAR2, -- 108
    distribution_att9	  IN OUT NOCOPY  VARCHAR2, -- 109
    distribution_att10	  IN OUT NOCOPY  VARCHAR2, -- 110
    distribution_att11	  IN OUT NOCOPY  VARCHAR2, -- 111
    distribution_att12	  IN OUT NOCOPY  VARCHAR2, -- 112
    distribution_att13	  IN OUT NOCOPY  VARCHAR2, -- 113
    distribution_att14	  IN OUT NOCOPY  VARCHAR2, -- 114
    distribution_att15	  IN OUT NOCOPY  VARCHAR2, -- 115
    result_code           OUT NOCOPY     NUMBER,  -- 116
    x_error_msg           OUT NOCOPY     VARCHAR2 -- 117
)
is

xx_project_id NUMBER;


BEGIN

   xx_project_id := to_number(header_att10);

   -- some comments here
   project_id := to_number(header_att10);
   -- and here



   if xx_project_id is not null then
   SELECT min(task_id)
   INTO task_id
   FROM pa_tasks
   WHERE chargeable_flag = 'Y'
   AND project_id = to_number(header_att10);

   expenditure_Type := nvl(line_att2,header_att12);
   expenditure_organization_id := 85;

   expenditure_item_date := need_by_date;

   END IF;




   RESULT_CODE:=0;
   X_ERROR_MSG:='';


  exception
  when no_data_found then

   RESULT_CODE:=1;
   X_ERROR_MSG:='This project does not have a default task';


END;

-- Customize this procedure to add logic for validation of the attribute values
-- on a requisition distribution. This would be any custom validation, that
-- would be in addition to all the validations done for a requisition
-- distribution.
-- The return_msg and the error_code can be used to return the results of
-- the validation
-- The return code can be used to indicate on which tab the error message
-- needs to be displayed on the Edit Lines page
-- If the result code is 1, error is displayed on the Delivery tab
-- If the result code is 2, error is displayed on the Billing tab
-- If the result code is 3, error is displayed on the Accounts tab

PROCEDURE CUSTOM_VALIDATE_REQ_DIST (

    x_distribution_id IN NUMBER, -- 1
    x_code_combination_id   IN   NUMBER, -- 2
    x_budget_account_id   IN    NUMBER, -- 3
    x_variance_account_id   IN   NUMBER, -- 4
    x_accrual_account_id   IN    NUMBER, -- 5
    project_id		      IN NUMBER, -- 6
    task_id		      IN NUMBER, -- 7
    expenditure_type	      IN VARCHAR2, -- 8
    expenditure_organization_id IN NUMBER, -- 9
    expenditure_item_date    IN DATE, -- 10
    award_id                 IN NUMBER, -- 11
    gl_encumbered_date	     IN DATE,	-- 12
    gl_period_name           IN VARCHAR2, -- 13
    gl_cancelled_date        IN DATE, -- 14
    gl_closed_date           IN DATE,--15
    gl_date                  IN DATE,--16
    gl_encumbered_period     IN VARCHAR2,--17
    recovery_rate            IN NUMBER, -- 18
    tax_recovery_override_flag IN VARCHAR2, -- 19
    chart_of_accounts_id     IN  NUMBER, -- 20
    category_id 	     IN  NUMBER, -- 21
    catalog_source           IN  VARCHAR2, -- 22
    catalog_type             IN  VARCHAR2, -- 23
    destination_type_code    IN  VARCHAR2, -- 24
    deliver_to_location_id   IN  NUMBER, -- 25
    destination_organization_id IN NUMBER, -- 26
    destination_subinventory IN  VARCHAR2, -- 27
    item_id			IN  NUMBER, -- 28
    sob_id                      IN NUMBER, -- 29
    currency_code               IN VARCHAR2, -- 30
    currency_unit_price         IN NUMBER, -- 31
    manufacturer_name           IN VARCHAR2, -- 32
    manufacturer_part_num       IN VARCHAR2,-- 33
    need_by_date                IN DATE, -- 34
    new_supplier_flag           IN VARCHAR2, -- 35
    business_org_id             IN NUMBER,    -- 36
    org_id                      IN NUMBER, -- 37
    employee_id                 IN NUMBER, -- 38
    employee_org_id       IN      NUMBER,  -- 39
    default_code_combination_id IN NUMBER, -- 40
    parent_req_line_id       IN  NUMBER, -- 41
    qty_cancelled            IN  NUMBER, -- 42
    qty_delivered            IN  NUMBER, -- 43
    qty_ordered              IN  NUMBER, -- 44
    qty_received             IN  NUMBER, -- 45
    rate                     IN  NUMBER, -- 46
    rate_date                IN  DATE, -- 47
    rate_type                IN  VARCHAR2, -- 48
    source_type_code         IN  VARCHAR2, -- 49
    spsc_code                IN  VARCHAR2, -- 50
    suggested_buyer_id       IN  NUMBER, -- 51
    source_doc_header_id     IN  NUMBER, -- 52
    source_doc_line_num      IN  NUMBER, -- 53
    source_doc_type_code     IN  VARCHAR2, -- 54
    supplier_item_num        IN  VARCHAR2, -- 55
    taxable_status           IN  VARCHAR2, -- 56
    unit_of_measure          IN  VARCHAR2, -- 57
    unit_price               IN  NUMBER, -- 58
    supplier_contact_id      IN  NUMBER, -- 59
    supplier_id              IN  NUMBER, -- 60
    supplier_site_id         IN  NUMBER, -- 61
    pcard_flag               IN  VARCHAR2, -- 62
    line_type_id	     IN  NUMBER, -- 63
    taxCodeId	             IN   NUMBER, -- 64
    results_billable_flag    IN VARCHAR2,-- 65
    preparer_id	   	     IN  NUMBER, -- 66
    deliver_to_person_id	IN  NUMBER, -- 67
    po_encumberance_flag	IN  VARCHAR2, -- 68
    DATE_FORMAT		IN  VARCHAR2,	-- 69
    header_att1		  IN  VARCHAR2,	-- 70
    header_att2		  IN  VARCHAR2,	-- 71
    header_att3		  IN  VARCHAR2,	-- 72
    header_att4		  IN  VARCHAR2,	-- 73
    header_att5		  IN  VARCHAR2,	-- 74
    header_att6		  IN  VARCHAR2,	-- 75
    header_att7		  IN  VARCHAR2,	-- 76
    header_att8		  IN  VARCHAR2,	-- 77
    header_att9		  IN  VARCHAR2,	-- 78
    header_att10	  IN  VARCHAR2,	-- 79
    header_att11	  IN  VARCHAR2,	-- 80
    header_att12	  IN  VARCHAR2,	-- 81
    header_att13          IN  VARCHAR2,	-- 82
    header_att14	  IN  VARCHAR2,	-- 83
    header_att15	  IN  VARCHAR2,	-- 84
    line_att1		  IN  VARCHAR2,	-- 85
    line_att2		  IN  VARCHAR2,	-- 86
    line_att3		  IN  VARCHAR2,	-- 87
    line_att4		  IN  VARCHAR2,	-- 88
    line_att5		  IN  VARCHAR2,	-- 89
    line_att6		  IN  VARCHAR2,	-- 90
    line_att7		  IN  VARCHAR2,	-- 91
    line_att8		  IN  VARCHAR2,	-- 92
    line_att9		  IN  VARCHAR2,	-- 93
    line_att10		  IN  VARCHAR2,	-- 94
    line_att11		  IN  VARCHAR2,	-- 95
    line_att12		  IN  VARCHAR2,	-- 96
    line_att13		  IN  VARCHAR2,	-- 97
    line_att14		  IN  VARCHAR2,	-- 98
    line_att15		  IN  VARCHAR2,	-- 99
    distribution_att1	  IN   VARCHAR2, -- 100
    distribution_att2	  IN   VARCHAR2, -- 101
    distribution_att3	  IN   VARCHAR2, -- 102
    distribution_att4	  IN   VARCHAR2, -- 103
    distribution_att5	  IN   VARCHAR2, -- 104
    distribution_att6	  IN   VARCHAR2, -- 105
    distribution_att7	  IN   VARCHAR2, -- 106
    distribution_att8	  IN   VARCHAR2, -- 107
    distribution_att9	  IN   VARCHAR2, -- 108
    distribution_att10	  IN   VARCHAR2, -- 109
    distribution_att11	  IN   VARCHAR2, -- 110
    distribution_att12	  IN   VARCHAR2, -- 111
    distribution_att13	  IN   VARCHAR2, -- 112
    distribution_att14	  IN   VARCHAR2, -- 113
    distribution_att15	  IN   VARCHAR2, -- 114
    result_code           OUT NOCOPY     NUMBER,  -- 115
    x_error_msg           OUT NOCOPY     VARCHAR2 -- 116
)
IS
xx_tmp VARCHAR2(10);
xx_tmp_project_id NUMBER;
xx_project_num VARCHAR2(60);
l_template_id number;


BEGIN



-- validate if updates have affected code
--  IF to_number(header_att10) <> project_id THEN

--  UPDATE po_req_distributions_all
--  SET project_id = to_number(header_att10),
--  task_id = (SELECT task_id FROM pa_tasks WHERE chargeable_flag = 'Y' AND task_name = 'Default' AND project_id = to_number(header_att10))
--  WHERE distribution_id = x_distribution_id;

--  END IF;






-- Additional AWAS logice
xx_tmp_project_id := project_id;
-- first get project number
SELECT segment1
INTO xx_project_num
FROM pa_projects_all p
WHERE p.project_id = xx_tmp_project_id;

/*   Commenting out for now


-- check is Project number is Entity 1801,1802,1804

if xx_project_num not in ('1801','1802','1804') then

-- first check to see if this is the BLS template, if so allow access to all areas.
SELECT nvl(noncat_template_id ,-1)
into l_template_id
FROM po_requisition_lines_all l,
po_req_distributions_all d
WHERE d.distribution_id = x_distribution_id
AND d.requisition_line_id = l.requisition_line_id;

        IF l_template_id <> 442  -- 442 is the BLS template
        THEN
        -- As it isnt an admin project, see if user is assigned to project
          SELECT max(xx_project_user(project_id,deliver_to_person_id ) )
          into xx_tmp
          from dual;

                IF xx_tmp IS NULL THEN

                RESULT_CODE:=2;
                X_ERROR_MSG:='The Requester is not authorised to buy for this project';
                else
                   RESULT_CODE:=0;
                   X_ERROR_MSG:='';
                END IF;

        else
                RESULT_CODE:=0;
                X_ERROR_MSG:='';
        END IF;

ELSE
    RESULT_CODE:=0;
    X_ERROR_MSG:='';

END IF;

  */
  -- remove next lines when uncommenting above
  RESULT_CODE:=0;
    X_ERROR_MSG:='';



EXCEPTION
   WHEN NO_DATA_FOUND THEN


      RESULT_CODE:=0;
      X_ERROR_MSG:='';

END;


-- Customize this procedure to handle updates to charge accounts.
-- The caller passes the charge account segments values in p_seg_vals,
-- and the new segments values should be returned in the same parameter.
-- Null is passed for the value of the read-only and hidden segments.
-- p_changed_seg is the index of the segment that the user changed this time.
-- p_orig_ccid is the CCID in the distribution before any user changes.
-- Any changes made by the user before a submit event are not reflected in
-- p_orig_ccid.

PROCEDURE CUSTOM_UPDATE_CHARGE_ACCOUNT(
  p_orig_ccid   IN     NUMBER, -- the code-combination ID before any user changes
  p_changed_seg IN     NUMBER, -- index of the changed segment (starts at 0)
  p_seg_vals    IN OUT NOCOPY POR_CHARGE_ACCT_SEG_TBL_TYPE, -- table of segment values
  result_code      OUT NOCOPY NUMBER,
  x_error_msg      OUT NOCOPY VARCHAR2
)
IS
BEGIN
  result_code := 0;
  x_error_msg := '';
END;

-- Since we will be obsoleting existing wf for RCO Req Approval tolerance
-- check, this procedure is provided to implement a hook for existing
-- customizations.
--
--  Parameters :
--    p_chreqgrp_id    : change request group id
--    x_appr_status    : approval status
--    x_skip_std_logic : determines whether standard tolerance check
--                       product logic will be skipped after calling
--                       this procedure or not.
PROCEDURE CUSTOM_RCO_REQAPPR_TOL_CHECK (
  p_chreqgrp_id IN NUMBER,
  x_appr_status OUT NOCOPY VARCHAR2,
  x_skip_std_logic OUT NOCOPY VARCHAR2 ) IS
BEGIN
  x_appr_status := 'Y';
  x_skip_std_logic := 'N';
END;


END POR_CUSTOM_PKG;
/
