/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/foundation.dart';


/** This is an auto generated class representing the Profiles type in your schema. */
@immutable
class Profiles extends Model {
  static const classType = const _ProfilesModelType();
  final String id;
  final String? _profile_name;
  final double? _min_temperature;
  final double? _max_temperature;
  final double? _min_humidity;
  final double? _max_humidity;
  final String? _usersID;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  ProfilesModelIdentifier get modelIdentifier {
      return ProfilesModelIdentifier(
        id: id
      );
  }
  
  String get profile_name {
    try {
      return _profile_name!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double? get min_temperature {
    return _min_temperature;
  }
  
  double? get max_temperature {
    return _max_temperature;
  }
  
  double? get min_humidity {
    return _min_humidity;
  }
  
  double? get max_humidity {
    return _max_humidity;
  }
  
  String get usersID {
    try {
      return _usersID!;
    } catch(e) {
      throw new AmplifyCodeGenModelException(
          AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Profiles._internal({required this.id, required profile_name, min_temperature, max_temperature, min_humidity, max_humidity, required usersID, createdAt, updatedAt}): _profile_name = profile_name, _min_temperature = min_temperature, _max_temperature = max_temperature, _min_humidity = min_humidity, _max_humidity = max_humidity, _usersID = usersID, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Profiles({String? id, required String profile_name, double? min_temperature, double? max_temperature, double? min_humidity, double? max_humidity, required String usersID}) {
    return Profiles._internal(
      id: id == null ? UUID.getUUID() : id,
      profile_name: profile_name,
      min_temperature: min_temperature,
      max_temperature: max_temperature,
      min_humidity: min_humidity,
      max_humidity: max_humidity,
      usersID: usersID);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Profiles &&
      id == other.id &&
      _profile_name == other._profile_name &&
      _min_temperature == other._min_temperature &&
      _max_temperature == other._max_temperature &&
      _min_humidity == other._min_humidity &&
      _max_humidity == other._max_humidity &&
      _usersID == other._usersID;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Profiles {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("profile_name=" + "$_profile_name" + ", ");
    buffer.write("min_temperature=" + (_min_temperature != null ? _min_temperature!.toString() : "null") + ", ");
    buffer.write("max_temperature=" + (_max_temperature != null ? _max_temperature!.toString() : "null") + ", ");
    buffer.write("min_humidity=" + (_min_humidity != null ? _min_humidity!.toString() : "null") + ", ");
    buffer.write("max_humidity=" + (_max_humidity != null ? _max_humidity!.toString() : "null") + ", ");
    buffer.write("usersID=" + "$_usersID" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Profiles copyWith({String? profile_name, double? min_temperature, double? max_temperature, double? min_humidity, double? max_humidity, String? usersID}) {
    return Profiles._internal(
      id: id,
      profile_name: profile_name ?? this.profile_name,
      min_temperature: min_temperature ?? this.min_temperature,
      max_temperature: max_temperature ?? this.max_temperature,
      min_humidity: min_humidity ?? this.min_humidity,
      max_humidity: max_humidity ?? this.max_humidity,
      usersID: usersID ?? this.usersID);
  }
  
  Profiles.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _profile_name = json['profile_name'],
      _min_temperature = (json['min_temperature'] as num?)?.toDouble(),
      _max_temperature = (json['max_temperature'] as num?)?.toDouble(),
      _min_humidity = (json['min_humidity'] as num?)?.toDouble(),
      _max_humidity = (json['max_humidity'] as num?)?.toDouble(),
      _usersID = json['usersID'],
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'profile_name': _profile_name, 'min_temperature': _min_temperature, 'max_temperature': _max_temperature, 'min_humidity': _min_humidity, 'max_humidity': _max_humidity, 'usersID': _usersID, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id, 'profile_name': _profile_name, 'min_temperature': _min_temperature, 'max_temperature': _max_temperature, 'min_humidity': _min_humidity, 'max_humidity': _max_humidity, 'usersID': _usersID, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<ProfilesModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<ProfilesModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField PROFILE_NAME = QueryField(fieldName: "profile_name");
  static final QueryField MIN_TEMPERATURE = QueryField(fieldName: "min_temperature");
  static final QueryField MAX_TEMPERATURE = QueryField(fieldName: "max_temperature");
  static final QueryField MIN_HUMIDITY = QueryField(fieldName: "min_humidity");
  static final QueryField MAX_HUMIDITY = QueryField(fieldName: "max_humidity");
  static final QueryField USERSID = QueryField(fieldName: "usersID");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Profiles";
    modelSchemaDefinition.pluralName = "Profiles";
    
    modelSchemaDefinition.authRules = [
      AuthRule(
        authStrategy: AuthStrategy.PUBLIC,
        operations: [
          ModelOperation.CREATE,
          ModelOperation.UPDATE,
          ModelOperation.DELETE,
          ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      ModelIndex(fields: const ["usersID"], name: "byUsers")
    ];
    
    modelSchemaDefinition.addField(ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Profiles.PROFILE_NAME,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Profiles.MIN_TEMPERATURE,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Profiles.MAX_TEMPERATURE,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Profiles.MIN_HUMIDITY,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Profiles.MAX_HUMIDITY,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: Profiles.USERSID,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _ProfilesModelType extends ModelType<Profiles> {
  const _ProfilesModelType();
  
  @override
  Profiles fromJson(Map<String, dynamic> jsonData) {
    return Profiles.fromJson(jsonData);
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Profiles] in your schema.
 */
@immutable
class ProfilesModelIdentifier implements ModelIdentifier<Profiles> {
  final String id;

  /** Create an instance of ProfilesModelIdentifier using [id] the primary key. */
  const ProfilesModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'ProfilesModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is ProfilesModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}