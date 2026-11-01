#+feature dynamic-literals

package data_loading

import "core:testing"
import "core:os"
import "core:fmt"
import "core:log"

Yaml_Testcase :: struct {
    filename: string,
    content: string,
    expected: Document,
    expected_error: Load_Error_Type,
    description: string,
}

@(test)
test_yaml_reader :: proc(t: ^testing.T) {
    defer free_all(context.allocator)

    temp_dir, err := os.make_directory_temp(
        "",
        "yaml_test_",
        context.allocator
    )

    if err != nil {
        testing.fail(t)
        return
    }

    defer os.remove_all(temp_dir)

    test_cases := []Yaml_Testcase {
        {
            filename = "missing_file.yaml",
            content = "missing",
            expected = Document{},
            expected_error = .FILE_NOT_FOUND,
            description = "File is missing",
        },
        {
            filename = "empty_file.yaml",
            content = "",
            expected = Document{},
            expected_error = .EMPTY_FILE,
            description = "File has no content",
        },
        {
            filename = "invalid_syntax.yaml",
            content =
            """
            name: Test
              age: 42
            """,
            expected = Document{},
            expected_error = .INVALID_FORMAT,
            description = "Invalid YAML indentation",
        },
        {
            filename = "valid_data_types.yaml",
            content =
            """
            string: Hello
            integer: 42
            float: 3.14
            boolean_true: true
            boolean_false: false
            null_value: null
            """,
            expected = Document {
                root = {
                    "string" = "Hello",
                    "integer" = i64(42),
                    "float" = f64(3.14),
                    "boolean_true" = true,
                    "boolean_false" = false,
                    "null_value" = Null{},
                },
            },
            expected_error = .NONE,
            description = "All supported scalar types",
        },
        {
            filename = "valid_quoted_strings.yaml",
            content =
            """
            quoted: "Hello: World"
            single_quoted: 'It''s working'
            """,
            expected = Document {
                root = {
                    "quoted" = "\"Hello: World\"",
                    "single_quoted" = "'It''s working'",
                },
            },
            expected_error = .NONE,
            description = "Quoted strings and special characters",
        },
        {
            filename = "valid_sequence.yaml",
            content = 
            """
            numbers:
              - 1
              - 2
              - 3
            """,
            expected = Document {
                root = {
                    "numbers" = []DocumentValue {
                        i64(1),
                        i64(2),
                        i64(3),
                    },
                },
            },
            expected_error = .NONE,
            description = "Valid sequence",
        },
        {
            filename = "valid_empty_sequence.yaml",
            content =
            """
            empty_sequence: []
            """,
            expected = Document {
                root = {
                    "empty_sequence" = Null{},
                },
            },
            expected_error = .NONE,
            description = "Empty sequence",
        },
        {
            filename = "not_supported_flow_mapping.yaml",
            content =
            """
            position: {}
            """,
            expected = {},
            expected_error = .INVALID_FORMAT,
            description = "Flow mappings are not supported",
        },
        {
            filename = "valid_mapping_with_sequence.yaml",
            content =
            """
            project:
              name: Bonk
              languages:
                - Odin
                - YAML
              versions:
                - 1
                - 2
                - 3
            """,
            expected = Document {
                root = {
                    "project" = map[string]DocumentValue {
                        "name" = "Bonk",
                        "languages" = []DocumentValue {
                            "Odin",
                            "YAML",
                        },
                        "versions" = []DocumentValue {
                            i64(1),
                            i64(2),
                            i64(3),
                        },
                    },
                },
            },
            expected_error = .NONE,
            description = "Mapping containing sequences",
        },
        {
           filename = "valid_sequence_with_mappings.yaml",
           content =
           """
           users:
             - name: Alice
               age: 25
             - name: Bob
               age: 30
           """,
           expected = Document {
               root = {
                   "users" = []DocumentValue {
                       map[string]DocumentValue {
                           "name" = "Alice",
                           "age" = i64(25),
                       },
                       map[string]DocumentValue {
                           "name" = "Bob",
                           "age" = i64(30),
                       },       
                   },
               },
           },
           expected_error = .NONE,
           description = "Sequence containing mappings",
        },
        {
            filename = "valid_nested_mapping.yaml",
            content =
            """
            game:
              window:
                width: 1920
                height: 1080
                fullscreen: true
              audio:
                master_volume: 0.8
                music_volume: 0.5
            """,
            expected = Document {
                root = {
                    "game" = map[string]DocumentValue {
                        "window" = map[string]DocumentValue {
                            "width" = i64(1920),
                            "height" = i64(1080),
                            "fullscreen" = true,
                        },
                        "audio" = map[string]DocumentValue {
                            "master_volume" = f64(0.8),
                            "music_volume" = f64(0.5),
                        },
                    },
                },
            },
            expected_error = .NONE,
            description = "Nested game configuration mapping",
        },
        {
            filename = "valid_complex_item.yaml",
            content =
            """
            id: healing_potion
            display_name: Trank der Heilung
            description: Stellt nach dem Trinken verlorene Lebenspunkte wieder her.
            type: drink
                
            stats:
              use_time: 1.0
              target: self
              effects:
                - id: instant_heal
                  overrides:
                    amount: 40
                
            assets:
              sprite: sprites/items/potions/healing_drink_potion_sheet.png
              animation:
                use:
                  frames: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
                  fps: 10
              audio:
                use: null
            """,
            expected = Document {
                root = {
                    "id" = "healing_potion",
                    "display_name" = "Trank der Heilung",
                    "description" = "Stellt nach dem Trinken verlorene Lebenspunkte wieder her.",
                    "type" = "drink",
                
                    "stats" = map[string]DocumentValue {
                        "use_time" = f64(1.0),
                        "target" = "self",
                        "effects" = []DocumentValue {
                            map[string]DocumentValue {
                                "id" = "instant_heal",
                                "overrides" = map[string]DocumentValue {
                                    "amount" = i64(40),
                                },
                            },
                        },
                    },
                
                    "assets" = map[string]DocumentValue {
                        "sprite" = "sprites/items/potions/healing_drink_potion_sheet.png",
                        "animation" = map[string]DocumentValue {
                            "use" = map[string]DocumentValue {
                                "frames" = []DocumentValue {
                                    i64(0), i64(1), i64(2), i64(3),
                                    i64(4), i64(5), i64(6), i64(7),
                                    i64(8), i64(9), i64(10), i64(11),
                                    i64(12), i64(13), i64(14), i64(15),
                                },
                                "fps" = i64(10),
                            },
                        },
                        "audio" = map[string]DocumentValue {
                            "use" = Null{},
                        },
                    },
                },
            },
            expected_error = .NONE,
            description = "Complex game item configuration",
        },
    }

    for test_case in test_cases {

        file_path := fmt.aprintf(
            "%s/%s",
            temp_dir,
            test_case.filename,
        )

        if test_case.content != "missing" {

            write_err := os.write_entire_file(
                file_path,
                test_case.content,
            )

            if write_err != nil {
                testing.fail(t)
                return
            }
        }

        document, load_err := yaml_reader(
            file_path,
            context.allocator,
        )

        ok := testing.expect_value(
            t,
            load_err.type,
            test_case.expected_error,
        )
        if !ok {
            log.errorf("%s unexpeced error behavior \nExpected: %v\nActual: %v\n%s", 
                test_case.description,
                test_case.expected_error,
                load_err.type,
                load_err.message
            )
        }

        if load_err.type == .NONE {
            ok := testing.expect(
                t,
                document_equals(document, test_case.expected),
                test_case.description,
            )
            if !ok {
                diff := document_diff(
                    test_case.expected,
                    document,
                    context.allocator,
                )
            
                log.errorf(
                    "%s\nDocument differences:\n%s\nExpected: %v\nActual: %v",
                    test_case.description,
                    diff,
                    test_case.expected,
                    document,
                )
            }
        }
    }
}
