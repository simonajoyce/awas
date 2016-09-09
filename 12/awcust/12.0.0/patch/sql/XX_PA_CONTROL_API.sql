CREATE OR REPLACE package xx_pa_control_api as 
/*============================================================================
| XX_PA_CONTROL_API Package Spec.                                            |
| This Package is used by WEB ADI to create or update Control Items in PA    |
| It calls the standard PA_CONTROL_API_PUB Package to to the insert ot update|
| Written By Simon Joyce, Version 1 24-Apr-2013                              |
=============================================================================*/

G_PA_MISS_NUM   CONSTANT   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
g_pa_miss_date  constant   date        := pa_interface_utils_pub.g_pa_miss_date;
G_PA_MISS_CHAR  CONSTANT   VARCHAR2(3) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

   PROCEDURE RMM
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
);

  PROCEDURE RETURN_PRR
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
);

 PROCEDURE DELIVERY_PRR
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
);

 PROCEDURE RETURN_PRR2
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
);

 PROCEDURE DELIVERY_PRR2
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
);

 PROCEDURE MAINTAIN_ISSUE
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
);
 
END XX_PA_CONTROL_API;
 
/


CREATE OR REPLACE package body xx_pa_control_api as

g_module_name     VARCHAR2(100) := 'pa.plsql.xx_PA_CONTROL_API';
l_debug_mode                 VARCHAR2(1);
l_debug_level3               CONSTANT NUMBER := 3;


 PROCEDURE RMM
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
)
as

begin
XX_PA_CONTROL_API.MAINTAIN_ISSUE(
    P_COMMIT => P_COMMIT,
    P_INIT_MSG_LIST => P_INIT_MSG_LIST,
    P_API_VERSION_NUMBER => P_API_VERSION_NUMBER,
    P_ORIG_SYSTEM_CODE => P_ORIG_SYSTEM_CODE,
    P_ORIG_SYSTEM_REFERENCE => P_ORIG_SYSTEM_REFERENCE,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    X_MSG_DATA => X_MSG_DATA,
    V_CI_ID => V_CI_ID,
    V_CI_NUMBER => V_CI_NUMBER,
    P_PROJECT_ID => P_PROJECT_ID,
    P_PROJECT_NAME => P_PROJECT_NAME,
    P_PROJECT_NUMBER => P_PROJECT_NUMBER,
    P_CI_TYPE_ID => P_CI_TYPE_ID,
    P_SUMMARY => P_SUMMARY,
    P_CI_NUMBER => P_CI_NUMBER,
    P_DESCRIPTION => P_DESCRIPTION,
    P_STATUS_CODE => P_STATUS_CODE,
    p_status => p_status,
    P_OWNER_ID => P_OWNER_ID,
    P_PROGRESS_STATUS_CODE => P_PROGRESS_STATUS_CODE,
    P_PROGRESS_AS_OF_DATE => P_PROGRESS_AS_OF_DATE,
    P_STATUS_OVERVIEW => P_STATUS_OVERVIEW,
    P_CLASSIFICATION_CODE => P_CLASSIFICATION_CODE,
    P_REASON_CODE => P_REASON_CODE,
    P_OBJECT_ID => P_OBJECT_ID,
    P_OBJECT_TYPE => P_OBJECT_TYPE,
    P_DATE_REQUIRED => P_DATE_REQUIRED,
    P_DATE_CLOSED => P_DATE_CLOSED,
    P_CLOSED_BY_ID => P_CLOSED_BY_ID,
    P_RESOLUTION => P_RESOLUTION,
    P_RESOLUTION_CODE => P_RESOLUTION_CODE,
    P_PRIORITY_CODE => P_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => P_EFFORT_LEVEL_CODE,
    P_PRICE => P_PRICE,
    P_PRICE_CURRENCY_CODE => P_PRICE_CURRENCY_CODE,
    P_SOURCE_TYPE_NAME => P_SOURCE_TYPE_NAME,
    P_SOURCE_TYPE_CODE => P_SOURCE_TYPE_CODE,
    P_SOURCE_NUMBER => P_SOURCE_NUMBER,
    P_SOURCE_COMMENT => P_SOURCE_COMMENT,
    P_SOURCE_DATE_RECEIVED => P_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => P_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => P_SOURCE_PERSON,
    P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => P_ATTRIBUTE1,
    P_ATTRIBUTE2 => P_ATTRIBUTE2,
    P_ATTRIBUTE3 => P_ATTRIBUTE3,
    P_ATTRIBUTE4 => P_ATTRIBUTE4,
    P_ATTRIBUTE5 => P_ATTRIBUTE5,
    P_ATTRIBUTE6 => P_ATTRIBUTE6,
    P_ATTRIBUTE7 => P_ATTRIBUTE7,
    P_ATTRIBUTE8 => P_ATTRIBUTE8,
    P_ATTRIBUTE9 => P_ATTRIBUTE9,
    P_ATTRIBUTE10 => P_ATTRIBUTE10,
    P_ATTRIBUTE11 => P_ATTRIBUTE11,
    P_ATTRIBUTE12 => P_ATTRIBUTE12,
    P_ATTRIBUTE13 => P_ATTRIBUTE13,
    P_ATTRIBUTE14 => P_ATTRIBUTE14,
    p_attribute15 => p_attribute15
  );
end RMM;

PROCEDURE Return_prr
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
)
as

begin
XX_PA_CONTROL_API.MAINTAIN_ISSUE(
    P_COMMIT => P_COMMIT,
    P_INIT_MSG_LIST => P_INIT_MSG_LIST,
    P_API_VERSION_NUMBER => P_API_VERSION_NUMBER,
    P_ORIG_SYSTEM_CODE => P_ORIG_SYSTEM_CODE,
    P_ORIG_SYSTEM_REFERENCE => P_ORIG_SYSTEM_REFERENCE,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    X_MSG_DATA => X_MSG_DATA,
    V_CI_ID => V_CI_ID,
    V_CI_NUMBER => V_CI_NUMBER,
    P_PROJECT_ID => P_PROJECT_ID,
    P_PROJECT_NAME => P_PROJECT_NAME,
    P_PROJECT_NUMBER => P_PROJECT_NUMBER,
    P_CI_TYPE_ID => P_CI_TYPE_ID,
    P_SUMMARY => P_SUMMARY,
    P_CI_NUMBER => P_CI_NUMBER,
    P_DESCRIPTION => P_DESCRIPTION,
    P_STATUS_CODE => P_STATUS_CODE,
    p_status => p_status,
    P_OWNER_ID => P_OWNER_ID,
    P_PROGRESS_STATUS_CODE => P_PROGRESS_STATUS_CODE,
    P_PROGRESS_AS_OF_DATE => P_PROGRESS_AS_OF_DATE,
    P_STATUS_OVERVIEW => P_STATUS_OVERVIEW,
    P_CLASSIFICATION_CODE => P_CLASSIFICATION_CODE,
    P_REASON_CODE => P_REASON_CODE,
    P_OBJECT_ID => P_OBJECT_ID,
    P_OBJECT_TYPE => P_OBJECT_TYPE,
    P_DATE_REQUIRED => P_DATE_REQUIRED,
    P_DATE_CLOSED => P_DATE_CLOSED,
    P_CLOSED_BY_ID => P_CLOSED_BY_ID,
    P_RESOLUTION => P_RESOLUTION,
    P_RESOLUTION_CODE => P_RESOLUTION_CODE,
    P_PRIORITY_CODE => P_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => P_EFFORT_LEVEL_CODE,
    P_PRICE => P_PRICE,
    P_PRICE_CURRENCY_CODE => P_PRICE_CURRENCY_CODE,
    P_SOURCE_TYPE_NAME => P_SOURCE_TYPE_NAME,
    P_SOURCE_TYPE_CODE => P_SOURCE_TYPE_CODE,
    P_SOURCE_NUMBER => P_SOURCE_NUMBER,
    P_SOURCE_COMMENT => P_SOURCE_COMMENT,
    P_SOURCE_DATE_RECEIVED => P_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => P_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => P_SOURCE_PERSON,
    P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => P_ATTRIBUTE1,
    P_ATTRIBUTE2 => P_ATTRIBUTE2,
    P_ATTRIBUTE3 => P_ATTRIBUTE3,
    P_ATTRIBUTE4 => P_ATTRIBUTE4,
    P_ATTRIBUTE5 => P_ATTRIBUTE5,
    P_ATTRIBUTE6 => P_ATTRIBUTE6,
    P_ATTRIBUTE7 => P_ATTRIBUTE7,
    P_ATTRIBUTE8 => P_ATTRIBUTE8,
    P_ATTRIBUTE9 => P_ATTRIBUTE9,
    P_ATTRIBUTE10 => P_ATTRIBUTE10,
    P_ATTRIBUTE11 => P_ATTRIBUTE11,
    P_ATTRIBUTE12 => P_ATTRIBUTE12,
    P_ATTRIBUTE13 => P_ATTRIBUTE13,
    P_ATTRIBUTE14 => P_ATTRIBUTE14,
    p_attribute15 => p_attribute15
  );
  
end return_prr;

PROCEDURE delivery_prr
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
)
as

begin
XX_PA_CONTROL_API.MAINTAIN_ISSUE(
    P_COMMIT => P_COMMIT,
    P_INIT_MSG_LIST => P_INIT_MSG_LIST,
    P_API_VERSION_NUMBER => P_API_VERSION_NUMBER,
    P_ORIG_SYSTEM_CODE => P_ORIG_SYSTEM_CODE,
    P_ORIG_SYSTEM_REFERENCE => P_ORIG_SYSTEM_REFERENCE,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    X_MSG_DATA => X_MSG_DATA,
    V_CI_ID => V_CI_ID,
    V_CI_NUMBER => V_CI_NUMBER,
    P_PROJECT_ID => P_PROJECT_ID,
    P_PROJECT_NAME => P_PROJECT_NAME,
    P_PROJECT_NUMBER => P_PROJECT_NUMBER,
    P_CI_TYPE_ID => P_CI_TYPE_ID,
    P_SUMMARY => P_SUMMARY,
    P_CI_NUMBER => P_CI_NUMBER,
    P_DESCRIPTION => P_DESCRIPTION,
    P_STATUS_CODE => P_STATUS_CODE,
    p_status => p_status,
    P_OWNER_ID => P_OWNER_ID,
    P_PROGRESS_STATUS_CODE => P_PROGRESS_STATUS_CODE,
    P_PROGRESS_AS_OF_DATE => P_PROGRESS_AS_OF_DATE,
    P_STATUS_OVERVIEW => P_STATUS_OVERVIEW,
    P_CLASSIFICATION_CODE => P_CLASSIFICATION_CODE,
    P_REASON_CODE => P_REASON_CODE,
    P_OBJECT_ID => P_OBJECT_ID,
    P_OBJECT_TYPE => P_OBJECT_TYPE,
    P_DATE_REQUIRED => P_DATE_REQUIRED,
    P_DATE_CLOSED => P_DATE_CLOSED,
    P_CLOSED_BY_ID => P_CLOSED_BY_ID,
    P_RESOLUTION => P_RESOLUTION,
    P_RESOLUTION_CODE => P_RESOLUTION_CODE,
    P_PRIORITY_CODE => P_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => P_EFFORT_LEVEL_CODE,
    P_PRICE => P_PRICE,
    P_PRICE_CURRENCY_CODE => P_PRICE_CURRENCY_CODE,
    P_SOURCE_TYPE_NAME => P_SOURCE_TYPE_NAME,
    P_SOURCE_TYPE_CODE => P_SOURCE_TYPE_CODE,
    P_SOURCE_NUMBER => P_SOURCE_NUMBER,
    P_SOURCE_COMMENT => P_SOURCE_COMMENT,
    P_SOURCE_DATE_RECEIVED => P_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => P_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => P_SOURCE_PERSON,
    P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => P_ATTRIBUTE1,
    P_ATTRIBUTE2 => P_ATTRIBUTE2,
    P_ATTRIBUTE3 => P_ATTRIBUTE3,
    P_ATTRIBUTE4 => P_ATTRIBUTE4,
    P_ATTRIBUTE5 => P_ATTRIBUTE5,
    P_ATTRIBUTE6 => P_ATTRIBUTE6,
    P_ATTRIBUTE7 => P_ATTRIBUTE7,
    P_ATTRIBUTE8 => P_ATTRIBUTE8,
    P_ATTRIBUTE9 => P_ATTRIBUTE9,
    P_ATTRIBUTE10 => P_ATTRIBUTE10,
    P_ATTRIBUTE11 => P_ATTRIBUTE11,
    P_ATTRIBUTE12 => P_ATTRIBUTE12,
    P_ATTRIBUTE13 => P_ATTRIBUTE13,
    P_ATTRIBUTE14 => P_ATTRIBUTE14,
    p_attribute15 => p_attribute15
  );
end DELIVERY_PRR;

PROCEDURE RETURN_PRR2
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
)
as

begin
XX_PA_CONTROL_API.MAINTAIN_ISSUE(
    P_COMMIT => P_COMMIT,
    P_INIT_MSG_LIST => P_INIT_MSG_LIST,
    P_API_VERSION_NUMBER => P_API_VERSION_NUMBER,
    P_ORIG_SYSTEM_CODE => P_ORIG_SYSTEM_CODE,
    P_ORIG_SYSTEM_REFERENCE => P_ORIG_SYSTEM_REFERENCE,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    X_MSG_DATA => X_MSG_DATA,
    V_CI_ID => V_CI_ID,
    V_CI_NUMBER => V_CI_NUMBER,
    P_PROJECT_ID => P_PROJECT_ID,
    P_PROJECT_NAME => P_PROJECT_NAME,
    P_PROJECT_NUMBER => P_PROJECT_NUMBER,
    P_CI_TYPE_ID => P_CI_TYPE_ID,
    P_SUMMARY => P_SUMMARY,
    P_CI_NUMBER => P_CI_NUMBER,
    P_DESCRIPTION => P_DESCRIPTION,
    P_STATUS_CODE => P_STATUS_CODE,
    p_status => p_status,
    P_OWNER_ID => P_OWNER_ID,
    P_PROGRESS_STATUS_CODE => P_PROGRESS_STATUS_CODE,
    P_PROGRESS_AS_OF_DATE => P_PROGRESS_AS_OF_DATE,
    P_STATUS_OVERVIEW => P_STATUS_OVERVIEW,
    P_CLASSIFICATION_CODE => P_CLASSIFICATION_CODE,
    P_REASON_CODE => P_REASON_CODE,
    P_OBJECT_ID => P_OBJECT_ID,
    P_OBJECT_TYPE => P_OBJECT_TYPE,
    P_DATE_REQUIRED => P_DATE_REQUIRED,
    P_DATE_CLOSED => P_DATE_CLOSED,
    P_CLOSED_BY_ID => P_CLOSED_BY_ID,
    P_RESOLUTION => P_RESOLUTION,
    P_RESOLUTION_CODE => P_RESOLUTION_CODE,
    P_PRIORITY_CODE => P_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => P_EFFORT_LEVEL_CODE,
    P_PRICE => P_PRICE,
    P_PRICE_CURRENCY_CODE => P_PRICE_CURRENCY_CODE,
    P_SOURCE_TYPE_NAME => P_SOURCE_TYPE_NAME,
    P_SOURCE_TYPE_CODE => P_SOURCE_TYPE_CODE,
    P_SOURCE_NUMBER => P_SOURCE_NUMBER,
    P_SOURCE_COMMENT => P_SOURCE_COMMENT,
    P_SOURCE_DATE_RECEIVED => P_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => P_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => P_SOURCE_PERSON,
    P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => P_ATTRIBUTE1,
    P_ATTRIBUTE2 => P_ATTRIBUTE2,
    P_ATTRIBUTE3 => P_ATTRIBUTE3,
    P_ATTRIBUTE4 => P_ATTRIBUTE4,
    P_ATTRIBUTE5 => P_ATTRIBUTE5,
    P_ATTRIBUTE6 => P_ATTRIBUTE6,
    P_ATTRIBUTE7 => P_ATTRIBUTE7,
    P_ATTRIBUTE8 => P_ATTRIBUTE8,
    P_ATTRIBUTE9 => P_ATTRIBUTE9,
    P_ATTRIBUTE10 => P_ATTRIBUTE10,
    P_ATTRIBUTE11 => P_ATTRIBUTE11,
    P_ATTRIBUTE12 => P_ATTRIBUTE12,
    P_ATTRIBUTE13 => P_ATTRIBUTE13,
    P_ATTRIBUTE14 => P_ATTRIBUTE14,
    p_attribute15 => p_attribute15
  );
  
end return_prr2;

PROCEDURE DELIVERY_PRR2
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          in date     := g_pa_miss_date,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
)
as

begin
XX_PA_CONTROL_API.MAINTAIN_ISSUE(
    P_COMMIT => P_COMMIT,
    P_INIT_MSG_LIST => P_INIT_MSG_LIST,
    P_API_VERSION_NUMBER => P_API_VERSION_NUMBER,
    P_ORIG_SYSTEM_CODE => P_ORIG_SYSTEM_CODE,
    P_ORIG_SYSTEM_REFERENCE => P_ORIG_SYSTEM_REFERENCE,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    X_MSG_DATA => X_MSG_DATA,
    V_CI_ID => V_CI_ID,
    V_CI_NUMBER => V_CI_NUMBER,
    P_PROJECT_ID => P_PROJECT_ID,
    P_PROJECT_NAME => P_PROJECT_NAME,
    P_PROJECT_NUMBER => P_PROJECT_NUMBER,
    P_CI_TYPE_ID => P_CI_TYPE_ID,
    P_SUMMARY => P_SUMMARY,
    P_CI_NUMBER => P_CI_NUMBER,
    P_DESCRIPTION => P_DESCRIPTION,
    P_STATUS_CODE => P_STATUS_CODE,
    p_status => p_status,
    P_OWNER_ID => P_OWNER_ID,
    P_PROGRESS_STATUS_CODE => P_PROGRESS_STATUS_CODE,
    P_PROGRESS_AS_OF_DATE => P_PROGRESS_AS_OF_DATE,
    P_STATUS_OVERVIEW => P_STATUS_OVERVIEW,
    P_CLASSIFICATION_CODE => P_CLASSIFICATION_CODE,
    P_REASON_CODE => P_REASON_CODE,
    P_OBJECT_ID => P_OBJECT_ID,
    P_OBJECT_TYPE => P_OBJECT_TYPE,
    P_DATE_REQUIRED => P_DATE_REQUIRED,
    P_DATE_CLOSED => P_DATE_CLOSED,
    P_CLOSED_BY_ID => P_CLOSED_BY_ID,
    P_RESOLUTION => P_RESOLUTION,
    P_RESOLUTION_CODE => P_RESOLUTION_CODE,
    P_PRIORITY_CODE => P_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => P_EFFORT_LEVEL_CODE,
    P_PRICE => P_PRICE,
    P_PRICE_CURRENCY_CODE => P_PRICE_CURRENCY_CODE,
    P_SOURCE_TYPE_NAME => P_SOURCE_TYPE_NAME,
    P_SOURCE_TYPE_CODE => P_SOURCE_TYPE_CODE,
    P_SOURCE_NUMBER => P_SOURCE_NUMBER,
    P_SOURCE_COMMENT => P_SOURCE_COMMENT,
    P_SOURCE_DATE_RECEIVED => P_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => P_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => P_SOURCE_PERSON,
    P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => P_ATTRIBUTE1,
    P_ATTRIBUTE2 => P_ATTRIBUTE2,
    P_ATTRIBUTE3 => P_ATTRIBUTE3,
    P_ATTRIBUTE4 => P_ATTRIBUTE4,
    P_ATTRIBUTE5 => P_ATTRIBUTE5,
    P_ATTRIBUTE6 => P_ATTRIBUTE6,
    P_ATTRIBUTE7 => P_ATTRIBUTE7,
    P_ATTRIBUTE8 => P_ATTRIBUTE8,
    P_ATTRIBUTE9 => P_ATTRIBUTE9,
    P_ATTRIBUTE10 => P_ATTRIBUTE10,
    P_ATTRIBUTE11 => P_ATTRIBUTE11,
    P_ATTRIBUTE12 => P_ATTRIBUTE12,
    P_ATTRIBUTE13 => P_ATTRIBUTE13,
    P_ATTRIBUTE14 => P_ATTRIBUTE14,
    p_attribute15 => p_attribute15
  );
end delivery_prr2;





PROCEDURE MAINTAIN_ISSUE
(
p_commit                                        IN VARCHAR2 := FND_API.G_TRUE,
p_init_msg_list                                 in varchar2 := FND_API.G_TRUE,
p_api_version_number                            in number   := 1.0,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      out nocopy varchar2,
v_ci_id                                         in out number,
v_ci_number                                     IN OUT NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          IN DATE     := G_PA_MISS_DATE,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 in varchar2 := g_pa_miss_char,
p_attribute_category                            IN VARCHAR2 := 'PRR',
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   in varchar2 := g_pa_miss_char
) AS

x_ci_id                                         number;
x_ci_number                                     number;
p_ci_id                                         number;
p_ci_status_code varchar2(200);
p_progress_overview varchar2(200);
p_status_comment varchar2(200);
p_resolution_comment varchar2(200);
p_record_version_number number;
p_owner_comment varchar2(200);
p_max_msg_count number;
 p_owner_name varchar2(200);
  p_highlighted_flag varchar2(200);
p_object_name varchar2(200);
P_OPEN_ACTION_NUM NUMBER;


Z_return_status                                varchar2(200);
z_msg_count                                     number;
Z_msg_data                                      varchar2(2000);

--Local Variables
          l_msg_count               NUMBER := 0;
          l_data                    VARCHAR2(2000);
          l_msg_data                VARCHAR2(2000);
          l_msg_index_out           number;
          l_module_name             VARCHAR2(200):='XX_PA_CONTROL_API.Maintain_issue';
        
          l_owner_id                number;
          l_status_code             pa_control_items.status_code%type;
          L_ATTRIBUTE_CATEGORY      VARCHAR2(24):= 'PRR';
          z_ci_id                  number;
                   
--exceptions
	api_exception exception;
        
        
        
  cursor c1 is
  select ci_id, ci_type_id, summary, status_code, owner_id, highlighted_flag, progress_status_code, progress_as_of_date, 
classification_code_id,
reason_code_id,
record_version_number,
project_id,
date_required,
description,
status_overview,
resolution,
resolution_code_id,
priority_code,
effort_level_code
from pa_control_items where CI_ID = v_ci_id;

CURSOR c_old_or_new  IS
SELECT CI_ID 
FROM PA_CONTROL_ITEMS I, PA_PROJECTS_ALL P
WHERE I.PROJECT_ID = P.PROJECT_ID
AND I.CI_TYPE_ID = P_CI_TYPE_ID
AND I.SOURCE_NUMBER = P_SOURCE_NUMBER
and p.segment1 = p_project_number;
        
  begin 
  
  p_record_version_number := g_pa_miss_num;
  
 -- Debug info
  insert into xx_debug  values (sysdate,'check','XX_PA_CONTROL_API.MAINTAIN_ISSUE','v_ci_id='||v_ci_id,null);
  insert into xx_debug  values (sysdate,'p_project_name='||p_project_name,'XX_PA_CONTROL_API.MAINTAIN_ISSUE','v_ci_id='||v_ci_id,null);
  INSERT INTO XX_DEBUG  VALUES (SYSDATE,'owner_id='||P_OWNER_ID,'XX_PA_CONTROL_API.MAINTAIN_ISSUE','v_ci_id='||V_CI_ID,NULL);
  INSERT INTO XX_DEBUG  VALUES (SYSDATE,'project_id='||P_PROJECT_ID,'XX_PA_CONTROL_API.MAINTAIN_ISSUE',NULL,NULL);
  INSERT INTO XX_DEBUG  VALUES (SYSDATE,'project_number='||P_PROJECT_NUMBER,'XX_PA_CONTROL_API.MAINTAIN_ISSUE',NULL,NULL);
  INSERT INTO XX_DEBUG  VALUES (SYSDATE,'ci_type_id='||P_CI_TYPE_ID,'XX_PA_CONTROL_API.MAINTAIN_ISSUE',NULL,NULL);
  insert into xx_debug  values (sysdate,'source_number='||p_source_number,'XX_PA_CONTROL_API.MAINTAIN_ISSUE',null,null);
  
  commit;
  
  z_ci_id  := v_ci_id;
  
  FOR R1 IN C_OLD_OR_NEW
  LOOP
  Z_CI_ID := R1.CI_ID;
  END LOOP;
  
  insert into xx_debug  values (sysdate,'owner_id='||p_owner_id,'XX_PA_CONTROL_API.MAINTAIN_ISSUE','z_ci_id='||z_ci_id,null);
  
  -- Update or Insert, check by looking for 
  if z_ci_id is null  or z_ci_id = 0 -- Insert
  then
  
  insert into xx_debug  values (sysdate,'Doing an Insert','XX_PA_CONTROL_API.MAINTAIN_ISSUE','z_ci_id='||z_ci_id,null);
  
  l_owner_id := p_owner_id;
  -- get project manager if owner id is null
  
  if p_owner_id is null then
                  select
                  resource_party_id
                  into l_owner_id
                FROM
                  pa_project_parties_v x,
                  pa_projects_all p
                WHERE
                  party_type         <> 'ORGANIZATION'
                and project_role_type = 'PROJECT MANAGER'
                and sysdate between start_date_active and nvl(end_date_active,sysdate+1)
                and x.project_id        = p.project_id
                and p.name = p_project_name;

  end if;
  
  PA_CONTROL_API_PUB.CREATE_ISSUE(
    p_commit => p_commit,
    p_init_msg_list => p_init_msg_list,
    p_api_version_number => p_api_version_number,
    p_orig_system_code => p_orig_system_code,
    P_ORIG_SYSTEM_REFERENCE => P_ORIG_SYSTEM_REFERENCE,
    x_return_status => z_return_status,
    x_msg_count => z_msg_count,
    X_MSG_DATA => Z_MSG_DATA,
    X_CI_ID => X_CI_ID,
    X_CI_NUMBER => X_CI_NUMBER,
    P_PROJECT_ID => p_PROJECT_ID,
    P_PROJECT_NAME => p_PROJECT_NAME,
    P_PROJECT_NUMBER => p_PROJECT_NUMBER,
    P_CI_TYPE_ID => p_CI_TYPE_ID,
    P_SUMMARY => p_SUMMARY,
    P_CI_NUMBER => p_CI_NUMBER,
    P_DESCRIPTION => p_DESCRIPTION,
    P_STATUS_CODE => p_STATUS_CODE,
    P_STATUS => p_STATUS,
    P_OWNER_ID => l_OWNER_ID,
    P_PROGRESS_STATUS_CODE => p_PROGRESS_STATUS_CODE,
    P_PROGRESS_AS_OF_DATE => p_PROGRESS_AS_OF_DATE,
    P_STATUS_OVERVIEW => p_STATUS_OVERVIEW,
    P_CLASSIFICATION_CODE => p_CLASSIFICATION_CODE,
    P_REASON_CODE => p_REASON_CODE,
    P_OBJECT_ID => p_OBJECT_ID,
    P_OBJECT_TYPE => p_OBJECT_TYPE,
    P_DATE_REQUIRED => p_DATE_REQUIRED,
    P_DATE_CLOSED => p_DATE_CLOSED,
    P_CLOSED_BY_ID => p_CLOSED_BY_ID,
    P_RESOLUTION => p_RESOLUTION,
    P_RESOLUTION_CODE => p_RESOLUTION_CODE,
    P_PRIORITY_CODE => p_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => p_EFFORT_LEVEL_CODE,
    P_PRICE => p_PRICE,
    p_price_currency_code => p_price_currency_code,
    P_SOURCE_TYPE_NAME => p_SOURCE_TYPE_NAME,
    P_SOURCE_TYPE_CODE => p_SOURCE_TYPE_CODE,
    P_SOURCE_NUMBER => p_SOURCE_NUMBER,
    P_SOURCE_COMMENT => p_SOURCE_COMMENT,
    P_SOURCE_DATE_RECEIVED => p_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => p_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => p_SOURCE_PERSON,
    P_ATTRIBUTE_CATEGORY => l_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => p_ATTRIBUTE1,
    P_ATTRIBUTE2 => p_ATTRIBUTE2,
    P_ATTRIBUTE3 => p_ATTRIBUTE3,
    P_ATTRIBUTE4 => p_ATTRIBUTE4,
    p_attribute5 => p_attribute5,
    p_attribute6 => p_attribute6,
    p_attribute7 => p_attribute7,
    P_ATTRIBUTE8 => p_ATTRIBUTE8,
    p_attribute9 => p_attribute9,
    p_attribute10 => p_attribute10,
    P_ATTRIBUTE11 => p_ATTRIBUTE11,
    P_ATTRIBUTE12 => p_ATTRIBUTE12,
    P_ATTRIBUTE13 => p_ATTRIBUTE13,
    P_ATTRIBUTE14 => p_ATTRIBUTE14,
    P_ATTRIBUTE15 => p_ATTRIBUTE15
  );
  
  if Z_return_status = 'E' then 
   raise api_exception;
   end if;
  
  else  --Update
  
  insert into xx_debug  values (sysdate,'update','XX_PA_CONTROL_API.MAINTAIN_ISSUE','v_ci_id='||v_ci_id,null);
  commit;
  
  -- use cursor to check for changes.
  for r1 in c1
  loop
  
  if r1.owner_id = p_owner_id then l_owner_id := g_pa_miss_num; else l_owner_id := p_owner_id; end if;
  
  end loop;
  
  
  
  
  
  p_ci_id      := z_ci_id;
  p_ci_status_code := p_status_code ;
  p_progress_overview := p_status_overview;
  p_status_comment := p_status;
  p_resolution_comment := p_resolution;  
  
  
  
  pa_control_api_pub.update_issue(
    P_COMMIT => P_COMMIT,
    P_INIT_MSG_LIST => P_INIT_MSG_LIST,
    P_API_VERSION_NUMBER => P_API_VERSION_NUMBER,
    X_RETURN_STATUS => Z_RETURN_STATUS,
    X_MSG_COUNT => Z_MSG_COUNT,
    x_msg_data => z_msg_data,
    p_ci_id => p_ci_id,
    p_record_version_number => p_record_version_number,
    P_SUMMARY => p_SUMMARY,
    P_DESCRIPTION => p_DESCRIPTION,
    p_owner_id => l_owner_id,
    P_OWNER_COMMENT => p_OWNER_COMMENT,
    p_classification_code => p_classification_code,
    p_reason_code => p_reason_code,
    P_OBJECT_ID => p_OBJECT_ID,
    P_OBJECT_TYPE => p_OBJECT_TYPE,
    P_CI_NUMBER => p_CI_NUMBER,
    P_DATE_REQUIRED => p_DATE_REQUIRED,
    P_PRIORITY_CODE => p_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => p_EFFORT_LEVEL_CODE,
    P_PRICE => p_PRICE,
    P_PRICE_CURRENCY_CODE => p_PRICE_CURRENCY_CODE,
    P_SOURCE_TYPE_CODE => p_SOURCE_TYPE_CODE,
    P_SOURCE_NUMBER => p_SOURCE_NUMBER,
    P_SOURCE_COMMENT => p_SOURCE_COMMENT,
    P_SOURCE_DATE_RECEIVED => p_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => p_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => p_SOURCE_PERSON,
    p_ci_status_code => p_ci_status_code,
    P_STATUS_COMMENT => p_STATUS_COMMENT,
    P_PROGRESS_AS_OF_DATE => p_PROGRESS_AS_OF_DATE,
    p_progress_status_code => p_progress_status_code,
    P_PROGRESS_OVERVIEW => p_PROGRESS_OVERVIEW,
    P_RESOLUTION_CODE => p_RESOLUTION_CODE,
    P_RESOLUTION_COMMENT => p_RESOLUTION_COMMENT,
    P_ATTRIBUTE_CATEGORY => l_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => p_ATTRIBUTE1,
    P_ATTRIBUTE2 => p_ATTRIBUTE2,
    p_attribute3 => p_attribute3,
    p_attribute4 => p_attribute4,
    p_attribute5 => p_attribute5,
    p_attribute6 => p_attribute6,
    p_attribute7 => p_attribute7,
    p_attribute8 => p_attribute8,
    p_attribute9 => p_attribute9,
    p_attribute10 => p_attribute10,
    P_ATTRIBUTE11 => p_ATTRIBUTE11,
    P_ATTRIBUTE12 => p_ATTRIBUTE12,
    P_ATTRIBUTE13 => p_ATTRIBUTE13,
    P_ATTRIBUTE14 => p_ATTRIBUTE14,
    p_attribute15 => p_attribute15
  ); 
  
  /*
   pa_control_items_pub.update_control_item(
    P_API_VERSION => P_API_VERSION_NUMBER,
    P_INIT_MSG_LIST => P_INIT_MSG_LIST,
    p_commit => p_commit,
    P_VALIDATE_ONLY => 'F',
    P_MAX_MSG_COUNT => P_MAX_MSG_COUNT,
    P_CI_ID => P_CI_ID,
    P_CI_TYPE_ID => P_CI_TYPE_ID,
    P_SUMMARY => P_SUMMARY,
    P_STATUS_CODE => P_STATUS_CODE,
    P_OWNER_ID => P_OWNER_ID,
    P_OWNER_NAME => P_OWNER_NAME,
    P_HIGHLIGHTED_FLAG => P_HIGHLIGHTED_FLAG,
    P_PROGRESS_STATUS_CODE => P_PROGRESS_STATUS_CODE,
    P_PROGRESS_AS_OF_DATE => P_PROGRESS_AS_OF_DATE,
    P_CLASSIFICATION_CODE => P_CLASSIFICATION_CODE,
    P_REASON_CODE => P_REASON_CODE,
    P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
    P_PROJECT_ID => P_PROJECT_ID,
    P_OBJECT_TYPE => P_OBJECT_TYPE,
    P_OBJECT_ID => P_OBJECT_ID,
    P_OBJECT_NAME => P_OBJECT_NAME,
    P_CI_NUMBER => P_CI_NUMBER,
    P_DATE_REQUIRED => P_DATE_REQUIRED,
    P_DATE_CLOSED => P_DATE_CLOSED,
    P_CLOSED_BY_ID => P_CLOSED_BY_ID,
    P_DESCRIPTION => P_DESCRIPTION,
    P_STATUS_OVERVIEW => P_STATUS_OVERVIEW,
    P_RESOLUTION => P_RESOLUTION,
    P_RESOLUTION_CODE => P_RESOLUTION_CODE,
    P_PRIORITY_CODE => P_PRIORITY_CODE,
    P_EFFORT_LEVEL_CODE => P_EFFORT_LEVEL_CODE,
    P_OPEN_ACTION_NUM => P_OPEN_ACTION_NUM,
    P_PRICE => P_PRICE,
    P_PRICE_CURRENCY_CODE => P_PRICE_CURRENCY_CODE,
    P_SOURCE_TYPE_CODE => P_SOURCE_TYPE_CODE,
    P_SOURCE_COMMENT => P_SOURCE_COMMENT,
    P_SOURCE_NUMBER => P_SOURCE_NUMBER,
    P_SOURCE_DATE_RECEIVED => P_SOURCE_DATE_RECEIVED,
    P_SOURCE_ORGANIZATION => P_SOURCE_ORGANIZATION,
    P_SOURCE_PERSON => P_SOURCE_PERSON,
    P_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
    P_ATTRIBUTE1 => P_ATTRIBUTE1,
    P_ATTRIBUTE2 => P_ATTRIBUTE2,
    P_ATTRIBUTE3 => P_ATTRIBUTE3,
    P_ATTRIBUTE4 => P_ATTRIBUTE4,
    P_ATTRIBUTE5 => P_ATTRIBUTE5,
    P_ATTRIBUTE6 => P_ATTRIBUTE6,
    P_ATTRIBUTE7 => P_ATTRIBUTE7,
    P_ATTRIBUTE8 => P_ATTRIBUTE8,
    P_ATTRIBUTE9 => P_ATTRIBUTE9,
    P_ATTRIBUTE10 => P_ATTRIBUTE10,
    P_ATTRIBUTE11 => P_ATTRIBUTE11,
    P_ATTRIBUTE12 => P_ATTRIBUTE12,
    P_ATTRIBUTE13 => P_ATTRIBUTE13,
    P_ATTRIBUTE14 => P_ATTRIBUTE14,
    P_ATTRIBUTE15 => P_ATTRIBUTE15,
    X_RETURN_STATUS => X_RETURN_STATUS,
    X_MSG_COUNT => X_MSG_COUNT,
    x_msg_data => x_msg_data
  );
   */
   
   if Z_return_status = 'E' then 
   
   insert into xx_debug  values (sysdate,'z_return_status:','XX_PA_CONTROL_API.MAINTAIN_ISSUE','z_return_status:'||z_return_status,null);
   insert into xx_debug  values (sysdate,'z_msg_count:','XX_PA_CONTROL_API.MAINTAIN_ISSUE','z_msg_count:'||z_msg_count,null);
   insert into xx_debug  values (sysdate,'z_msg_data:','XX_PA_CONTROL_API.MAINTAIN_ISSUE','z_msg_count:'||z_msg_data,null);
   commit;
   
   raise api_exception;
   end if;
   
   
   
  end if;
  
  EXCEPTION
  when fnd_api.g_exc_unexpected_error then

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_issue;
            end if;
            FND_MSG_PUB.Count_And_Get(
                                      p_count     =>  x_msg_count ,
                                      p_data      =>  x_msg_data  );

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --rest the stack;
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

--AWAS
  fnd_message.set_name('BNE','WEBADI_ERROR'); 
  fnd_message.set_token('MSG', 'Error 1:'||x_msg_data); 
--end AWAS

  when fnd_api.g_exc_error then

         --x_return_status := fnd_api.g_ret_sts_error;
         --do a rollback;
           -- if p_commit = fnd_api.g_true then
             --    rollback to  create_issue;
          --  end if;
         l_msg_count := fnd_msg_pub.count_msg;
         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                                   (p_encoded        => fnd_api.g_false,
                                    p_msg_index      => 1,
                                    p_msg_count      => l_msg_count ,
                                    p_msg_data       => l_msg_data ,
                                    p_data           => l_data,
                                    p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

--AWAS
  fnd_message.set_name('BNE','WEBADI_ERROR'); 
  fnd_message.set_token('MSG', 'Error 2:'||Z_msg_data); 
--end AWAS

  when api_exception then 
  
  fnd_message.set_name('BNE','WEBADI_ERROR'); 
  fnd_message.set_token('MSG', 'Error 4 - API Exception:'||Z_msg_data); 
  
  insert into xx_debug  values (sysdate,'Error 4 - API Exception:','XX_PA_CONTROL_API.MAINTAIN_ISSUE','Error 4 - API Exception:'||p_init_msg_list,null);
  insert into xx_debug  values (sysdate,'Error 4 - API Exception:','XX_PA_CONTROL_API.MAINTAIN_ISSUE','Error 4 - API Exception:'||l_data,null);
  
  commit;
  
  
  
  when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_issue;
            end if;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_API_PUB',
                                 p_procedure_name => 'create_issue',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => Z_msg_count,
                                   p_data  => z_msg_data);

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;
    --AWAS
  fnd_message.set_name('BNE','WEBADI_ERROR'); 
  fnd_message.set_token('MSG', 'Error 3:'||substrb(sqlerrm,1,240)||Z_msg_data); 
--end AWAS
    
    
  END MAINTAIN_ISSUE;

END XX_PA_CONTROL_API;
/
