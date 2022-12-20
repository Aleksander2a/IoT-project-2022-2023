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


/** This is an auto generated class representing the SensorData type in your schema. */
@immutable
class SensorData extends Model {
  static const classType = const _SensorDataModelType();
  final String id;
  final double? _temperature;
  final double? _humidity;
  final double? _pressure;
  final String? _usersID;
  final TemporalDateTime? _creation_time;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  SensorDataModelIdentifier get modelIdentifier {
      return SensorDataModelIdentifier(
        id: id
      );
  }
  
  double? get temperature {
    return _temperature;
  }
  
  double? get humidity {
    return _humidity;
  }
  
  double? get pressure {
    return _pressure;
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
  
  TemporalDateTime get creation_time {
    try {
      return _creation_time!;
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
  
  const SensorData._internal({required this.id, temperature, humidity, pressure, required usersID, required creation_time, createdAt, updatedAt}): _temperature = temperature, _humidity = humidity, _pressure = pressure, _usersID = usersID, _creation_time = creation_time, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory SensorData({String? id, double? temperature, double? humidity, double? pressure, required String usersID, required TemporalDateTime creation_time}) {
    return SensorData._internal(
      id: id == null ? UUID.getUUID() : id,
      temperature: temperature,
      humidity: humidity,
      pressure: pressure,
      usersID: usersID,
      creation_time: creation_time);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SensorData &&
      id == other.id &&
      _temperature == other._temperature &&
      _humidity == other._humidity &&
      _pressure == other._pressure &&
      _usersID == other._usersID &&
      _creation_time == other._creation_time;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("SensorData {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("temperature=" + (_temperature != null ? _temperature!.toString() : "null") + ", ");
    buffer.write("humidity=" + (_humidity != null ? _humidity!.toString() : "null") + ", ");
    buffer.write("pressure=" + (_pressure != null ? _pressure!.toString() : "null") + ", ");
    buffer.write("usersID=" + "$_usersID" + ", ");
    buffer.write("creation_time=" + (_creation_time != null ? _creation_time!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  SensorData copyWith({double? temperature, double? humidity, double? pressure, String? usersID, TemporalDateTime? creation_time}) {
    return SensorData._internal(
      id: id,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      usersID: usersID ?? this.usersID,
      creation_time: creation_time ?? this.creation_time);
  }
  
  SensorData.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _temperature = (json['temperature'] as num?)?.toDouble(),
      _humidity = (json['humidity'] as num?)?.toDouble(),
      _pressure = (json['pressure'] as num?)?.toDouble(),
      _usersID = json['usersID'],
      _creation_time = json['creation_time'] != null ? TemporalDateTime.fromString(json['creation_time']) : null,
      _createdAt = json['createdAt'] != null ? TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'temperature': _temperature, 'humidity': _humidity, 'pressure': _pressure, 'usersID': _usersID, 'creation_time': _creation_time?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id, 'temperature': _temperature, 'humidity': _humidity, 'pressure': _pressure, 'usersID': _usersID, 'creation_time': _creation_time, 'createdAt': _createdAt, 'updatedAt': _updatedAt
  };

  static final QueryModelIdentifier<SensorDataModelIdentifier> MODEL_IDENTIFIER = QueryModelIdentifier<SensorDataModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField TEMPERATURE = QueryField(fieldName: "temperature");
  static final QueryField HUMIDITY = QueryField(fieldName: "humidity");
  static final QueryField PRESSURE = QueryField(fieldName: "pressure");
  static final QueryField USERSID = QueryField(fieldName: "usersID");
  static final QueryField CREATION_TIME = QueryField(fieldName: "creation_time");
  static var schema = Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "SensorData";
    modelSchemaDefinition.pluralName = "SensorData";
    
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
      key: SensorData.TEMPERATURE,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: SensorData.HUMIDITY,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: SensorData.PRESSURE,
      isRequired: false,
      ofType: ModelFieldType(ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: SensorData.USERSID,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(ModelFieldDefinition.field(
      key: SensorData.CREATION_TIME,
      isRequired: true,
      ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)
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

class _SensorDataModelType extends ModelType<SensorData> {
  const _SensorDataModelType();
  
  @override
  SensorData fromJson(Map<String, dynamic> jsonData) {
    return SensorData.fromJson(jsonData);
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [SensorData] in your schema.
 */
@immutable
class SensorDataModelIdentifier implements ModelIdentifier<SensorData> {
  final String id;

  /** Create an instance of SensorDataModelIdentifier using [id] the primary key. */
  const SensorDataModelIdentifier({
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
  String toString() => 'SensorDataModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is SensorDataModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}